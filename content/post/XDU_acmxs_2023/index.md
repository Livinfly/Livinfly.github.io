---
title: "2023年XDU-ACM校赛个人题解（部分）"
slug: "XDU_acmxs_2023"
authors: ["Livinfly(Mengmm)"]
date: 2023-05-19T00:00:00+08:00
# publishDate: 2023-10-01T00:00:00+08:00 # 定时发布
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/xcpc/XDU_acmxs_2023"]
categories: ["xcpc"]
tags: ["算法竞赛", "XDU校赛", "题解"]
description: "（旧文）2023XDU-ACM校赛个人题解 DEFGIJ部分"
image: "cover.jpg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

> 旧文

[题面PDF](https://acm.xidian.edu.cn/campus/2023/statements.pdf)

[补题链接](https://acm.xidian.edu.cn/problemset.php?search=2023+校赛现场赛)



## [D - 燃起来了！](https://acm.xidian.edu.cn/problem.php?id=1680)

期望题。

因为我做期望题很少，赛时直接跳了，后面推推感觉还行，大概设计好，有终结状态的状态信息一个就行（？）
$$
令 \space p = a/b, \space d = x/y, \space r = x\%y, E_i 为经过i次连续失败后，第i+1成功的时间长度的期望\\
E_0 = y + p \cdot E_0 + (1-p) \cdot E_1 \\
E_1 = y + p \cdot E_0 + (1-p) \cdot E_2 \\
E_2 = y + p \cdot E_0 + (1-p) \cdot E_3 \\ 
... \\ 
E_{d-1} = y + p \cdot E_0 + (1-p) \cdot E_d \\ 
E_d = r \\ 
\Rightarrow E_0 = r + y \cdot \sum_{i=1}^{d}{(\frac{1}{1-p})^i} \\ 
\Rightarrow E_0 = r + y \cdot \frac{(1-p)^d-1}{(1-p)^d \cdot (-p)}
$$

```cpp
#pragma GCC optimize(2)

#include <bits/stdc++.h>

#define fi first
#define se second
#define mkp(x, y) make_pair((x), (y))
#define all(x) (x).begin(), (x).end()

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;

const int MO = 1e9+7;

int qpm(int a, int b, const int &c = MO) { // int/LL
	int ans = 1 % c;
	while(b) {
		if(b & 1) ans = 1LL*ans*a % c;
		a = 1LL*a*a % c;
		b >>= 1;
	}
	return ans;
}

void solve() {
    int a, b, x, y;
    cin >> a >> b >> x >> y;
    if(a == b && y <= x) {
    	cout << "forever\n";
    	return;
    }
    int p = 1LL*a*qpm(b, MO-2) % MO, d = x/y, r = x%y;
    // cerr << y << ' ' << p << ' ' << d << ' ' << r << '\n';
    int ans = (1LL*y * (qpm(1-p, d) - 1)%MO * qpm(1LL*qpm(1-p, d) * (-p)%MO, MO-2) + r)% MO;
    ans = (ans + MO) % MO;
    cout << ans << '\n';
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("i.txt", "r", stdin);
    // freopen("o.txt", "w", stdout);
    // time_t t1 = clock();
    int Tcase = 1;
    cin >> Tcase; // scanf("%d", &Tcase);
    while (Tcase--) 
        solve();
    // cout << "time: " << 1000.0 * ((clock() - t1) / CLOCKS_PER_SEC) << "ms\n";
    return 0;
}
```



## [E - 全自动窗口调度算法](https://acm.xidian.edu.cn/problem.php?id=1681)

好像大家，把序列存下来纯模拟的多，我是维护每个窗口的最早空闲时间，然后更新就行。



```cpp
#include <bits/stdc++.h>

#define fi first
#define se second
#define all(a) (a).begin(), (a).end()

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;
typedef pair<LL, int> PLI;

void solve() {
	int n, m;
	cin >> n >> m;
	vector<LL> a(n), v(m), belong(n), cnt(m), t(m);
	for(auto &x : v) cin >> x;
	for(auto &x : a) cin >> x;
	sort(all(a));
	set<PII> st; // cnt, id
	set<PLI> done; // time, id
	for(int i = 0; i < m; i ++) 
		st.insert({0, i});
	for(int i = 0; i < n; i ++) {
		while(done.size() && done.begin()->fi <= a[i]) {
			int gid = belong[done.begin()->se];
			done.erase(done.begin());
			st.erase(st.find({cnt[gid], gid}));
			cnt[gid] --;
			st.insert({cnt[gid], gid});
		}
		auto [nn, gid] = *st.begin();
//		cout << nn << ' ' << gid << '\n';
		st.erase(st.begin());
		cnt[gid] ++;
		st.insert({cnt[gid], gid});
		done.insert({max(a[i], t[gid])+v[gid], i});
		belong[i] = gid;
//		cout << t[gid] << '\n';
		
		t[gid] = max(t[gid], a[i])+v[gid];
	}
	cout << (done.rbegin()->fi) << '\n';
}

int main() {
	ios::sync_with_stdio(0);
	cin.tie(0);
	cout << fixed;
	
	int Tcase = 1;
//	cin >> Tcase;
	while(Tcase --) 
		solve();
	
	return 0;
}
/*
3 1
100
1 10 301
*/
```





## [F - Z-O 平衡](https://acm.xidian.edu.cn/problem.php?id=1682)

### 做法1 - $O(n)$

~~大概骚扰luoyue一段时间后，明白了~~

考虑数字从左到右一个一个加入序列，每次加入，考虑新加入的数对前面所有序列和自己的总贡献。

由于奇偶的作用不一致，很自然地可以考虑一个序列的`奇数个数-偶数个数`不同时它对答案的贡献，即需要几次操作，会得到以下序列：

```
odd - even    -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6
			   3  3  2  2  1  1 0 2 1 3 2 4 3
```

可以找到，序列`奇 - 偶`为正数/负数，奇数/偶数，增加/减少时的影响，通过一个数组+偏移量，维护整个序列。

`base-delta`永远是`0`的位置。

upd. 有些佬表示好像还是不太明白变量含义，我这里统一解释下：

在当前偏移情况下，考虑所有连续子序列，negE 是`奇数-偶数的个数`是`负数且偶数`的个数，negO 是`奇数-偶数的个数`是`负数且奇数`的个数，pos就是正的奇数/偶数。zero就是`奇数-偶数 = 0`的个数，因为在发现的规律里，0是特殊的，需要额外记录。

```cpp
#pragma GCC optimize(2)

#include <bits/stdc++.h>

#define fi first
#define se second
#define mkp(x, y) make_pair((x), (y))
#define all(x) (x).begin(), (x).end()

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;

const int base = 2e5;

int delta;
LL ans, res;
int rec[base<<1];

void solve() {
    LL n, negE = 0, negO = 0, posE = 0, posO = 0, zero = 0;
    cin >> n;
    while(n --) {
    	LL x;
    	cin >> x;
    	if(x & 1) {
    		delta ++;
    		res = res - negO + posE*2 - posO + 2*zero + 2;
    		rec[base-delta+1] ++;
    		swap(posO, posE);
    		posO += zero;
    		posO ++;
    		swap(negO, negE);
    		zero = rec[base-delta];
    		negE -= zero;
    	}
    	else {
    		delta --;
    		res = res + negE + posE - 2*posO + zero + 1;
    		rec[base-delta-1] ++;
    		swap(posO, posE);
    		swap(negO, negE);
    		negO += zero;
    		negO ++;
    		zero = rec[base-delta];
    		posE -= zero;
    	}
    	// cerr << posO << ' ' << posE << ' ' << negO << ' ' << negE << '\n';
    	ans += res;
    }
    cout << ans << '\n';
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("i.txt", "r", stdin);
    // freopen("o.txt", "w", stdout);
    // time_t t1 = clock();
    int Tcase = 1;
    // cin >> Tcase; // scanf("%d", &Tcase);
    while (Tcase--) 
        solve();
    // cout << "time: " << 1000.0 * ((clock() - t1) / CLOCKS_PER_SEC) << "ms\n";
    return 0;
}
/*
odd - even    -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6
			   3  3  2  2  1  1 0 2 1 3 2 4 3
*/
```

### 做法2 - $O(nlogn)$

~~口糊一下好了，因为先看的O(n)做法~~

和第二种一样做偏移，用两个树状数组记录下前面序列的各个`奇数 - 偶数`的个数，一个记录结果为奇数的各个长度的个数，一个记录结果为偶数的各个长度的个数，树状数组来维护正负的个数的信息，然后强行把第一种$O(1)$维护的东西变成$O(logn)$维护的东西（（逃



## [G - 最强平行组合](https://acm.xidian.edu.cn/problem.php?id=1683)

因为选课没有限制选课相同，可以用背包最大化同个学分下的经验。

再用枚举二进制状态的做法，把每个学分的合法子集的最大值归为自己的值。

这种做法理论复杂度极高，但是出题人放过了（

~~求教std做法~~

```cpp
#pragma GCC optimize(2)

#include <bits/stdc++.h>

#define fi first
#define se second
#define mkp(x, y) make_pair((x), (y))
#define all(x) (x).begin(), (x).end()

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;

void solve() {
    int n, k;
    cin >> n >> k;
    vector<int> a(n), b(n), f(2e5+1, -1), g(2e5+1, -1);
   	for(auto &x : a) cin >> x;
   	for(auto &x : b) cin >> x;
   	f[0] = 0;
	for(int i = 0; i < n; i ++) {
		for(int j = 2e5; j >= a[i]; j --) {
			if(f[j-a[i]] != -1) {
				f[j] = max(f[j], f[j-a[i]] + b[i]);
			}
		}
	}
	for(int S = 1; S <= 2e5; S ++) {
		for(int T = S; T; T = (T-1) & S) {
			if(T < k) continue;
			g[S] = max(g[S], f[T]);
		}
	}
	int ans = -1;
	for(int i = 1; i <= 2e5; i ++) {
		if(g[i] != -1 && (i^((1<<18)-1)) <= 2e5 && g[i^((1<<18)-1)] != -1) {
			ans = max(ans, g[i] + g[i^((1<<18)-1)]);
		}
	}
	cout << ans << '\n';
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("i.txt", "r", stdin);
    // freopen("o.txt", "w", stdout);
    // time_t t1 = clock();
    int Tcase = 1;
    // cin >> Tcase; // scanf("%d", &Tcase);
    while (Tcase--) 
        solve();
    // cout << "time: " << 1000.0 * ((clock() - t1) / CLOCKS_PER_SEC) << "ms\n";
    return 0;
}
```

## [I - 你相信光吗](https://acm.xidian.edu.cn/problem.php?id=1685)

网络流板子题。

几个注意点，题目是有向图，加容量和恢复容量有些细节。

~~因为其实是赛时的代码再赛后略修一下，现在已经忘得差不多了~~

```cpp
#include <bits/stdc++.h>

#define fi first
#define se second
#define all(a) (a).begin(), (a).end()

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;

const int N = 310, M = 16000;
const LL INF = 1e18;

int idx, h[N], ne[M], ver[M];
LL e[M], rec[M];
int n, m, S, T, C;
int d[N], cur[N];

void add(int a, int b, LL c) {
	ver[idx] = b, e[idx] = c, ne[idx] = h[a], h[a] = idx ++;
}
bool bfs() {
	queue<int> q;
	memset(d, -1, sizeof d);
	q.push(S);
	d[S] = 0, cur[S] = h[S];
	while(q.size()) {
		int t = q.front(); q.pop();
		for(int i = h[t]; ~i; i = ne[i]) {
			int v = ver[i];
			if(d[v] == -1 && e[i]) {
				d[v] = d[t]+1;
				cur[v] = h[v];
				if(v == T) {
					return true;
				}
				q.push(v);
			}
		}
	}
	return false;
}
LL update(int u, LL limit) {
	if(u == T) return limit;
	LL flow = 0;
	for(int i = cur[u]; ~i && flow < limit; i = ne[i]) {
		cur[u] = i;
		int v = ver[i];
		if(d[v] == d[u]+1 && e[i]) {
			LL t = update(v, min(e[i], limit-flow));
			if(!t) d[v] = -1;
			flow += t;
			e[i] -= t;
			e[i^1] += t;
		}
	}
	return flow;
}
LL dinic() {
	LL res = 0, flow;
	while(bfs())
		while(flow = update(S, INF)) 
			res += flow;
	return res;
}

int main() {
	ios::sync_with_stdio(0);
	cin.tie(0);
	cout << fixed;
	memset(h, -1, sizeof h);
	cin >> n >> m >> C;
	S = 0, T = n;
	while(m --) {
		int a, b, c;
		cin >> a >> b >> c;
		rec[idx] = c;
		add(a, b, c), add(b, a, 0);
	}
	LL res = dinic(), r1 = 0, r2 = 0;
	vector<PII> vvv;
	for(int i = 0; i < idx; i += 2)
		if(e[i] == 0) 
			vvv.emplace_back(ver[i^1], ver[i]);
	for(auto [x, y] : vvv) {
		int tx = h[x], ty = h[y];
		for(int z = 0; z < idx; z += 2)
			e[z] += e[z^1], e[z^1] = 0;
		add(x, y, C), add(y, x, 0);
		LL tres = dinic();
		idx -= 2;
		h[x] = tx, h[y] = ty;
		if(tres > res) {
			res = tres;
			r1 = x, r2 = y;
		}
	}
	cout << r1 << ' ' << r2 << ' ' << res << '\n';
	return 0;
}
```



## [J - bzy 的出行](https://acm.xidian.edu.cn/problem.php?id=1686)

xorzj说，[Cow Relays G](https://www.luogu.com.cn/problem/P2886)是原题，需要的前置知识有，矩阵快速幂、floyd。

因为floyd和矩阵乘法的类似性（是可以这么说的么），用类似矩阵快速幂的形式预处理出`g[k, i, j]`，代表经过$2^k$条边，i 到 j 的最短路径长度。

不做预处理时间复杂度是$O(T \cdot n^3 \cdot log(1e9))$，会被卡飞。

然后有一个优化的点是，每次只有一个起点，所以求答案的那个数组可以用一维的，把时间复杂度降下来。

~~下方码风较凌乱~~

```cpp
#pragma GCC optimize(2)

#include <bits/stdc++.h>

#define fi first
#define se second
#define mkp(x, y) make_pair((x), (y))
#define all(x) (x).begin(), (x).end()

using namespace std;

typedef long long LL;
typedef pair<int, int> PII;

const int N = 210;
const LL INF = 0x3f3f3f3f3f3f3f3f;

LL g[31][N][N], f[N], ff[N], ans[N][N];

void solve() {
    int n, m;
    cin >> n >> m;
    memset(g, 0x3f, sizeof g);
    while(m --) {
        int a, b, c;
        cin >> a >> b >> c;
        g[0][a][b] = c;
    }
    int T;
    cin >> T;
    auto floyd = [&](LL a[N][N], LL b[N][N]) {
        memset(ans, 0x3f, sizeof ans);
        for(int k = 1; k <= n; k ++)
            for(int i = 1; i <= n; i ++)
                for(int j = 1; j <= n; j ++)
                    ans[i][j] = min(ans[i][j], a[i][k] + b[k][j]);
        memcpy(a, ans, sizeof ans);
        return;
    };
    for(int i = 1; i < 31; i ++) {
        memcpy(g[i], g[i-1], sizeof g[i-1]);
        floyd(g[i], g[i-1]);
    }
    auto floyd1 = [&](LL a[N], LL b[N][N]) {
        memset(ff, 0x3f, sizeof ff);
        for(int k = 1; k <= n; k ++)
            for(int i = 1; i <= n; i ++)
                ff[i] = min(ff[i], a[k] + b[k][i]);
        memcpy(a, ff, sizeof ff);
        return;
    };
    int s, k;
    auto qpm = [&](int k) {
        memset(f, 0x3f, sizeof f);
        f[s] = 0;
        int kk = 0;
        while(k) {
            if(k & 1) floyd1(f, g[kk]);
            k >>= 1;
            kk ++;
        }
        return;
    };
    while(T --) {
        cin >> s >> k;
        qpm(k);
        for(int i = 1; i <= n; i ++) {
            cout << (f[i] == INF ? -1 : f[i]) << " \n"[i == n];
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("i.txt", "r", stdin);
    // freopen("o.txt", "w", stdout);
    // time_t t1 = clock();
    int Tcase = 1;
    // cin >> Tcase; // scanf("%d", &Tcase);
    while (Tcase--) 
        solve();
    // cout << "time: " << 1000.0 * ((clock() - t1) / CLOCKS_PER_SEC) << "ms\n";
    return 0;
}
```

