---
title: "『学习笔记』CMU 15-445 (2024 fall) Homework #1 - SQL"
slug: "CMU_15-445_database_2024fall_HW1"
authors: ["Livinfly(Mengmm)"]
date: 2025-09-06T06:28:22Z
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/note/CMU_15-445_database_2024fall_HW1"]
categories: ["note"]
tags: ["学习笔记", "CMU_15-445", "数据库"]
description: "CMU 15-445 (2024 fall) Homework #1 - SQL."
image: "cover.jpeg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

# Homework #1 - SQL

> 封面来源：[@psychoron](https://x.com/psychoron/status/1890415031998673363)

[Homework #1 - SQL | CMU 15-445/645 :: Intro to Database Systems (Fall 2024)](https://15445.courses.cs.cmu.edu/fall2024/homework1/)

用 duckdb 生成的结果，如果有 `'` 单引号，会被双引号框起来，导致和 sqlite3 的结果不一致。

可手动去除或都用 sqlite3 跑。

同时可以使用 .mode 等命令，使得 duckdb 的输出格式和 sqlite 一致。

逃了，写 Q5 写得头晕，Q1 - 4 还是完成了，感觉已经起到基础锻炼效果了，基本都在翻 note / 问 ai / 做完看上一个的参考答案 = =

后面两个理清然后实现 sqlite 的版本。

中间遇到 `diff` 因为 LF 和 CRLF 的区别而显示不一致（（

具体的做法感觉也不用多说，就贴下代码吧。（Homework，官方有放 sol，所以也应该是允许的）

其他的作业因为是纸质，就不单独贴文章了。

## q1_sample.sqlite.sql

```sql
SELECT DISTINCT(name) FROM medal_info ORDER BY name;
```

## q2_successful_coaches.sqlite.sql

```sql
SELECT co.name, COUNT(*)
FROM coaches co
JOIN (
    SELECT m.winner_code, m.discipline, a.country_code
    FROM medals m
    JOIN athletes a ON m.winner_code = a.code
    UNION ALL
    SELECT DISTINCT m.winner_code, m.discipline, t.country_code
    FROM medals m
    JOIN teams t ON m.winner_code = t.code
) winners ON co.discipline = winners.discipline AND co.country_code = winners.country_code
GROUP BY co.code
ORDER BY COUNT(*) DESC, co.name ASC
;
```

## q3_Judo_athlete_medals.sqlite.sql

```sql
SELECT DISTINCT a.name, count(m.winner_code)
FROM athletes a
LEFT JOIN teams t ON a.code = t.athletes_code
LEFT JOIN medals m ON m.winner_code = a.code OR m.winner_code = t.code
WHERE a.disciplines LIKE '%Judo%'
GROUP BY a.name
ORDER BY count(m.winner_code) DESC, a.name
;
```

## q4_Athletics_venue_athletes.sqlite.sql

```sql
WITH p AS (
    SELECT *
    FROM athletes
    WHERE code in (
        SELECT DISTINCT participant_code
        FROM (
            SELECT participant_code
            FROM results r
            LEFT JOIN venues v ON r.venue = v.venue
            WHERE v.disciplines LIKE '%Athletics%' AND participant_type = 'Person'
            UNION
            SELECT athletes_code AS participant_code
            FROM teams t
            WHERE code IN (
                SELECT participant_code
                FROM results r
                LEFT JOIN venues v ON r.venue = v.venue
                WHERE v.disciplines LIKE '%Athletics%' AND participant_type = 'Team'
            )
        )
    )
)

SELECT p.name, p.country_code, p.nationality_code
FROM p
LEFT JOIN (
    SELECT code, c.Latitude cLatitude, c.Longitude cLongitude
    FROM countries c
) c1 ON p.country_code = c1.code
LEFT JOIN (
    SELECT code, c.Latitude nLatitude, c.Longitude nLongitude
    FROM countries c
) c2 ON p.nationality_code = c2.code
WHERE cLatitude IS NOT NULL AND cLongitude IS NOT NULL AND nLatitude IS NOT NULL AND nLongitude IS NOT NULL
ORDER BY (cLatitude - nLatitude) * (cLatitude - nLatitude) + (cLongitude - nLongitude) * (cLongitude - nLongitude) DESC, p.name
;
```

## q5_top5_rank_country_per_day.sqlite.sql

```sql

WITH t AS (
    SELECT code, country_code
    FROM teams
    GROUP BY code, country_code
), cr AS (
    SELECT code, 
        RANK() OVER (ORDER BY c."GDP ($ per capita)" DESC) gdprk,
        RANK() OVER (ORDER BY c.Population DESC) poprk
    FROM countries c
)

SELECT date, ccode, app, gdprk, poprk
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY date ORDER BY app DESC, ccode) as rn
    FROM (
        SELECT *, 
        CASE WHEN t.country_code IS NOT NULL THEN t.country_code ELSE a.country_code END AS ccode,
        COUNT(rank) as app
        FROM (
            results r LEFT JOIN t ON r.participant_code = t.code
            LEFT JOIN athletes a ON r.participant_code = a.code
        )
        WHERE rank <= 5
        GROUP BY date, ccode
    )
) ranked, cr
WHERE rn = 1 AND cr.code = ranked.ccode
ORDER BY date
;
```

## q6_big_progress_country_female_teams.sqlite.sql

```sql
with t as (
	select code, country_code from teams group by code, country_code
),
paris_medals as (
    select t2.country_code as country_code, count(t2.country_code) as medal_number 
    from
        (select 
            t1.medal_code, 
            case when t1.country_code is not null then t1.country_code else athletes.country_code end as country_code
        from 
            (select * from medals left join t on medals.winner_code = t.code) as t1 
            left join athletes on athletes.code = t1.winner_code
        ) as t2, 
        medal_info mi
    where t2.medal_code = mi.code and mi.name = 'Gold Medal'
    group by t2.country_code
    order by medal_number desc
),
cs as (
    select 
        paris_medals.country_code as country, 
        paris_medals.medal_number - tokyo_medals.gold_medal as progress
    from tokyo_medals, paris_medals
    where paris_medals.country_code = tokyo_medals.country_code
    order by progress desc
    limit 5
)

select country_code, progress as increased_gold_medal_number, tcode
from (
    select *, teams.code as tcode
    from athletes
    JOIN teams ON teams.athletes_code = athletes.code
    JOIN cs ON teams.country_code = cs.country
    group by teams.code
    having sum(1 - gender) = 0
    )
order by progress desc, country, tcode
;
```