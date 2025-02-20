---
title: "分块入门九题"
slug: "分块入门九题"
authors: ["Livinfly(Mengmm)"]
date: 2023-05-16T00:00:00+08:00
# publishDate: 2023-10-01T00:00:00+08:00 # 定时发布
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/算法竞赛/分块入门九题"]
categories: ["算法竞赛"]
tags: ["分块", "数据结构", "题解"]
description: "（旧文）做hzwer大佬的分块入门九题题单的记录"
image: "cover.png" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

>   本篇文章为旧文



# 分块入门九题

>   code by Livinfly

原文连接：[「分块」数列分块入门1 – 9 by hzwer - 分块 - hzwer.com](http://hzwer.com/8053.html)

开始前，先%%hzwer大佬

主要是贴我的代码，和发现的一些问题，主要思路的讲解hzwer学长已经讲得非常深入浅出了！

关于一些块的大小的取法，[数列分块总结——题目总版（hzwer分块九题及其他题目）（分块） - Flash_Hu - 博客园 (cnblogs.com)](https://www.cnblogs.com/flashhu/p/8437062.html)有提到一些，我这里就全方便起见取$\sqrt{n}$了。

分块入门九题的题目：[题库 - LibreOJ (loj.ac)](https://loj.ac/p?keyword=分块入门)

我在LOJ上提交都有记录，用户名为Livinfly，如有需要也可以去LOJ查看通过记录。

## 分块1

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

int n, bSize, bNum;
vector<int> a, belong, addTag;

void Add(int l, int r, int c) {
    int bl = belong[l], br = belong[r];
    if(bl == br) {
        for(int i = l; i <= r; i ++)
            a[i] += c;
    }
    else {
        for(int i = bl+1; i < br; i ++) {
            addTag[i] += c;
        }
        for(int i = l; i <= n && belong[i] == bl; i ++) {
            a[i] += c;
        }
        for(int i = r; i > 0 && belong[i] == br; i --) {
            a[i] += c;
        }
    }
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize+1;
    a.resize(n+1), belong.resize(n+1), addTag.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
        cin >> a[i];
    }
    while(n --) {
        int op, l, r, c;
        cin >> op >> l >> r >> c;
        if(op == 0) {
            Add(l, r, c);
        }
        else {
            cout << a[r] + addTag[belong[r]] << '\n';
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



## 分块2

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

int n, bSize, bNum;
vector<int> a, belong, addTag;
vector<vector<int>> va;

void Resort(int x) {
	va[x].clear();
	for(int i = (x-1)*bSize+1; i <= n && belong[i] == x; i ++) {
		va[x].push_back(a[i]);
	}
	sort(all(va[x]));
}
void Add(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			a[i] += c;
		}
		Resort(bl);
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			addTag[i] += c;
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			a[i] += c;
		}
		Resort(bl);
		for(int i = r; i > 0 && belong[i] == br; i --) {
			a[i] += c;
		}
		Resort(br);
	}
}
int Query(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	int ret = 0;
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			if(a[i]+addTag[bl] < c) {
				ret ++;
			}
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			int t = c-addTag[i];
			ret += (lower_bound(all(va[i]), t) - va[i].begin());
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			if(a[i]+addTag[bl] < c) {
				ret ++;
			}
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			if(a[i]+addTag[br] < c) {
				ret ++;
			}
		}
	}
	return ret;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize+1;
    a.resize(n+1), va.resize(bNum+1), belong.resize(n+1), addTag.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize+1;
    	va[belong[i]].push_back(a[i]);
    }
    for(int i = 1; i <= bNum; i ++) 
    	sort(all(va[i]));
    for(int i = 0; i < n; i ++) {
    	int op, l, r, c;
    	cin >> op >> l >> r >> c;
    	if(op == 0) {
    		Add(l, r, c);
    	}
    	else {
    		cout << Query(l, r, c*c) << '\n';
    	}
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("a2.in", "r", stdin);
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



## 分块3

这道题数据稍微弱了点，~~然后hzwer学长的std也假了，但是还是%%~~

std用`set`的`erase`会一次把所有的值删掉，但我们其实只删一个。

考虑用`multiset`，注意不要直接`erase`，这样也是全部一次删完，要`find`出来，删指针，才能删一个！

然后，时间复杂度做法1比假的set做法后面的点每个平均快100ms，multiset的时间更不忍直视（（

没有特别想清楚为什么qwq

~~留坑，如果有人知道的，可以email or qq教教我~~

### 做法1，同分块2的自己sort保证有序的性质

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

int n, bSize, bNum;
vector<int> a, belong, addTag;
vector<vector<int>> va;

void Resort(int x) {
	va[x].clear();
	for(int i = (x-1)*bSize+1; i <= n && belong[i] == x; i ++) {
		va[x].push_back(a[i]);
	}
	sort(all(va[x]));
}
void Add(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			a[i] += c;
		}
		Resort(bl);
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			addTag[i] += c;
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			a[i] += c;
		}
		Resort(bl);
		for(int i = r; i > 0 && belong[i] == br; i --) {
			a[i] += c;
		}
		Resort(br);
	}
}
int Query(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	int ret = -1;
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			if(a[i]+addTag[bl] < c) {
				ret = max(ret, a[i]+addTag[bl]);
			}
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			int t = c-addTag[i];
			auto iter = lower_bound(all(va[i]), t);
			if(iter != va[i].begin()) {
				// + addTag[i]
				ret = max(ret, *(-- iter) + addTag[i]);
			}
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			if(a[i]+addTag[bl] < c) {
				ret = max(ret, a[i]+addTag[bl]);
			}
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			if(a[i]+addTag[br] < c) {
				ret = max(ret, a[i]+addTag[br]);
			}
		}
	}
	return ret;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize+1;
    a.resize(n+1), va.resize(bNum+1), belong.resize(n+1), addTag.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize+1;
    	va[belong[i]].push_back(a[i]);
    }
    for(int i = 1; i <= bNum; i ++) 
    	sort(all(va[i]));
    for(int i = 0; i < n; i ++) {
    	int op, l, r, c;
    	cin >> op >> l >> r >> c;
    	if(op == 0) {
    		Add(l, r, c);
    	}
    	else {
    		cout << Query(l, r, c) << '\n';
    	}
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("a2.in", "r", stdin);
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



### 做法2，multiset

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

int n, bSize, bNum;
vector<int> a, belong, addTag;
vector<multiset<int>> va;

void Add(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			va[bl].erase(va[bl].find(a[i]));
			a[i] += c;
			va[bl].insert(a[i]);
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			addTag[i] += c;
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			va[bl].erase(va[bl].find(a[i]));
			a[i] += c;
			va[bl].insert(a[i]);
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			va[br].erase(va[br].find(a[i]));
			a[i] += c;
			va[br].insert(a[i]);
		}
	}
}
int Query(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	int ret = -1;
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			if(a[i]+addTag[bl] < c) {
				ret = max(ret, a[i]+addTag[bl]);
			}
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			int t = c-addTag[i];
			auto iter = va[i].lower_bound(t);
			if(iter != va[i].begin()) {
				// + addTag[i]
				ret = max(ret, *(-- iter) + addTag[i]);
			}
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			if(a[i]+addTag[bl] < c) {
				ret = max(ret, a[i]+addTag[bl]);
			}
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			if(a[i]+addTag[br] < c) {
				ret = max(ret, a[i]+addTag[br]);
			}
		}
	}
	return ret;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize+1;
    a.resize(n+1), va.resize(bNum+1), belong.resize(n+1), addTag.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize+1;
    	va[(i-1)/bSize+1].insert(a[i]);
    }
    for(int i = 0; i < n; i ++) {
    	int op, l, r, c;
    	cin >> op >> l >> r >> c;
    	if(op == 0) {
    		Add(l, r, c);
    	}
    	else {
    		cout << Query(l, r, c) << '\n';
    	}
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << fixed;  // << setprecision(20); // double
    // freopen("a2.in", "r", stdin);
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



## 分块4

注意开`long long`吧，我是直接过程转化了，看起来可能比较难看（逃

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

int n, bSize, bNum;
vector<int> a, belong, addTag, sum;

void Add(int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			a[i] += c;
			sum[bl] += c;
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			addTag[i] += c;
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			a[i] += c;
			sum[bl] += c;
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			a[i] += c;
			sum[br] += c;
		}
	}
}
int Query(int l, int r, const int &MO) {
	int bl = belong[l], br = belong[r];
	int ret = 0;
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			int x = (1LL*a[i] + addTag[bl]) % MO;
			ret = (1LL*ret + x) % MO;
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			int x = (1LL*sum[i] + 1LL*addTag[i]*bSize%MO) % MO;
			ret = (1LL*ret + x) % MO;
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			int x = (1LL*a[i] + addTag[bl]) % MO;
			ret = (1LL*ret + x) % MO;
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			int x = (1LL*a[i] + addTag[br]) % MO;
			ret = (1LL*ret + x) % MO;
		}
	}
	return ret;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), addTag.resize(bNum+1), sum.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize + 1;
    	sum[belong[i]] += a[i];
    }
    for(int i = 0; i < n; i ++) {
    	int op, l, r, c;
    	cin >> op >> l >> r >> c;
    	if(op == 0) {
    		Add(l, r, c);
    	}
    	else {
    		int MO = c+1;
    		cout << (Query(l, r, c+1)%MO+MO) % MO << '\n';
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



## 分块5

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

int n, bSize, bNum;
vector<int> a, belong, sum;
vector<bool> done;

void Modify(int l, int r) {
	int bl = belong[l], br = belong[r];
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			sum[bl] -= a[i];
			a[i] = sqrt(a[i]);
			sum[bl] += a[i];
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			if(done[i]) continue;
			done[i] = true;
            // 和n要取较小的值，循环里面i和j不要想错了qwq
			for(int j = (i-1)*bSize + 1; j <= min(i*bSize, n); j ++) {
				sum[i] -= a[j];
				a[j] = sqrt(a[j]);
				sum[i] += a[j];
				if(a[j] > 1) done[i] = false;
			}
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			sum[bl] -= a[i];
			a[i] = sqrt(a[i]);
			sum[bl] += a[i];
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			sum[br] -= a[i];
			a[i] = sqrt(a[i]);
			sum[br] += a[i];
		}
	}
}
int Query(int l, int r) {
	int bl = belong[l], br = belong[r];
	int ret = 0;
	if(bl == br) {
		for(int i = l; i <= r; i ++) {
			ret += a[i];
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			ret += sum[i];
		}
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			ret += a[i];
		}
		for(int i = r; i > 0 && belong[i] == br; i --) {
			ret += a[i];
		}
	}
	return ret;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), done.resize(bNum+1), sum.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize + 1;
    	sum[belong[i]] += a[i];
    }
    for(int i = 0; i < n; i ++) {
		int op, l, r, c;
		cin >> op >> l >> r >> c;
		if(op == 0) {
			Modify(l, r);
		}
		else {
			cout << Query(l, r) << '\n';
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



## 分块6

因为是随机数据，重新分块（重构）的代码注释掉也是可以过的。

不重新分块625ms，hzwer学长提到的每$\sqrt{n}$次重构一次，是391ms，std里的看起来挺玄学的重构条件是196ms，~~分块真是玄学（逃~~

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

int n, bSize, bNum;
vector<int> a, belong;
vector<vector<int>> va;

PII Find(int x) {
	int ret = 1;
	while(x > va[ret].size()) {
		x -= va[ret].size();
		ret ++;
	}
	return {ret, x-1};
}
void Rebuild() {
	a.assign(1, 0);
	for(int i = 1; i <= bNum; i ++) {
		a.insert(a.end(), va[i].begin(), va[i].end());
		va[i].clear();
	}
	n = a.size()-1;
	bSize = sqrt(n), bNum = (n-1)/bSize + 1;
	// 理论上只要更新bSize和va，但为了一致性，这里还是都更新了
	belong.resize(n+1), va.resize(bNum+1);
	for(int i = 1; i <= n; i ++) {
		belong[i] = (i-1)/bSize + 1;
		va[belong[i]].push_back(a[i]);
	}
}
void Insert(int x, int c) {
	auto [i, b] = Find(x);
	va[i].insert(va[i].begin() + b, c);
	// if(va[i].size() > 20*bSize) {
	// 	Rebuild();
	// }
}
int Query(int x) {
	auto [i, b] = Find(x);
	return va[i][b];
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), va.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize + 1;
    	va[belong[i]].push_back(a[i]);
    }
    int t = sqrt(n);
    // 由于n在重新分块时更新了，所以，这里循环询问的n要存到别的变量里面
    int nn = n;
    for(int i = 0; i < nn; i ++) {
    	int op, l, r, c;
    	cin >> op >> l >> r >> c;
    	if(op == 0) {
    		Insert(l, r);
    		// if(i % t == 0) {
    		// 	Rebuild();
    		// }
    	}
    	else {
    		cout << Query(r) << '\n';
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



## 分块7

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

const int MO = 10007;

int n, bSize, bNum;
vector<int> a, belong, addTag, mulTag;

void Reset(int x) {
	for(int i = (x-1)*bSize+1; i <= min(n, x*bSize); i ++)
		a[i] = (1LL*a[i]*mulTag[x] % MO + addTag[x]) % MO;
	mulTag[x] = 1, addTag[x] = 0;
}
void Modify(int op, int l, int r, int c) {
	int bl = belong[l], br = belong[r];
	if(bl == br) {
		Reset(bl);
		for(int i = l; i <= r; i ++) {
			if(op == 0) {
				a[i] = (1LL*a[i] + c) % MO;
			}
			else {
				a[i] = 1LL*a[i]*c % MO;
			}
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			if(op == 0) {
				addTag[i] = (1LL*addTag[i] + c) % MO;
			}
			else {
				addTag[i] = 1LL*addTag[i] * c % MO;
				mulTag[i] = 1LL*mulTag[i] * c % MO;
			}
		}
		Reset(bl);
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			if(op == 0) {
				a[i] = (1LL*a[i] + c) % MO;
			}
			else {
				a[i] = 1LL*a[i]*c % MO;
			}
		}
		Reset(br);
		for(int i = r; i > 0 && belong[i] == br; i --) {
			if(op == 0) {
				a[i] = (1LL*a[i] + c) % MO;
			}
			else {
				a[i] = 1LL*a[i]*c % MO;
			}
		}
	}
}
int Query(int x) {
	int bx = belong[x];
	return (1LL*a[x] * mulTag[bx] % MO + addTag[bx]) % MO;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), addTag.resize(bNum+1), mulTag.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize + 1;
    }
    for(int i = 1; i <= bNum; i ++) {
    	mulTag[i] = 1;
    }
    for(int i = 0; i < n; i ++) {
    	int op, l, r, c;
    	cin >> op >> l >> r >> c;
    	if(op == 2) {
    		cout << Query(r) << '\n';
    	}
    	else {
    		Modify(op, l, r, c);
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



## 分块8

需要去分析分块的时间复杂度，然后大胆分块暴力。

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

int n, bSize, bNum;
vector<int> a, belong, tag;

void Reset(int x) {
	if(tag[x] == -1) return;
	for(int i = (x-1)*bSize + 1; i <= min(n, x*bSize); i ++) {
		a[i] = tag[x];
	}
	tag[x] = -1;
}
int Query(int l, int r, int c) {
	int bl = belong[l], br = belong[r], ret = 0;
	if(bl == br) {
		Reset(bl);
		for(int i = l; i <= r; i ++) {
			if(a[i] == c) {
				ret ++;
			}
			else {
				a[i] = c;
			}
		}
	}
	else {
		for(int i = bl+1; i < br; i ++) {
			if(tag[i] == c) {
				ret += bSize;
			}
			else if(tag[i] == -1) {
				// i和j分清楚。。
				for(int j = (i-1)*bSize + 1; j <= min(n, i*bSize); j ++) {
					if(a[j] == c) {
						ret ++;
					}
				}
			}
			tag[i] = c;
		}
		Reset(bl);
		for(int i = l; i <= n && belong[i] == bl; i ++) {
			if(a[i] == c) {
				ret ++;
			}
			else {
				a[i] = c;
			}
		}
		Reset(br);
		for(int i = r; i > 0 && belong[i] == br; i --) {
			if(a[i] == c) {
				ret ++;
			}
			else {
				a[i] = c;
			}
		}
	}
	return ret;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), tag.assign(bNum+1, -1);
    for(int i = 1; i <= n; i ++) {
    	cin >> a[i];
    	belong[i] = (i-1)/bSize + 1;
    }
    for(int i = 0; i < n; i ++) {
    	int l, r, c;
    	cin >> l >> r >> c;
    	cout << Query(l, r, c) << '\n';
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



## 分块9

好多做法，都不会（



### 做法1 - 分块 - 预处理块区间

很容易可以判断，`[L, R]`的区间众数，一定是在`[L, R]`中一段连续的整块的众数和两边非完整块的数的并集内。

然后，我们就可以处理`f[i, j]`表示第 i 块到第 j 块区间的区间众数，不难发现，预处理的时间复杂度为$O(n \cdot 块数)$ ，是可以接受的，~~这实在是太神奇了！~~

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

int n, bSize, bNum;
vector<int> a, belong, cnt, val;
int nid;
map<int, int> mp;
vector<vector<int>> va, f;

void PrevCalc() {
    for(int i = 1; i <= bNum; i ++) {
        int mx = 0, res = 0;
        cnt.assign(n+1, 0);
        for(int j = (i-1)*bSize + 1; j <= n; j ++) {
            int bj = belong[j];
            cnt[a[j]] ++;
            if(cnt[a[j]] > mx || cnt[a[j]] == mx && val[a[j]] < val[res])
                mx = cnt[a[j]], res = a[j];
            f[i][bj] = res;
        }
    }
}
int Query(int l, int r, int c) {
    return (upper_bound(all(va[c]), r) - lower_bound(all(va[c]), l));
}
int Query(int l, int r) {
    int bl = belong[l], br = belong[r], ret = 0, mx = 0;
    if(bl == br) {
        for(int i = l; i <= r; i ++) {
            int t = Query(l, r, a[i]);
            if(t > mx || t == mx && val[a[i]] < val[ret]) {
                mx = t, ret = a[i];
            }
        }
    }
    else {
        ret = f[bl+1][br-1], mx = Query(l, r, ret);
        for(int i = l; i <= n && belong[i] == bl; i ++) {
            int t = Query(l, r, a[i]);
            if(t > mx || t == mx && val[a[i]] < val[ret]) {
                mx = t, ret = a[i];
            }
        }
        for(int i = r; i > 0 && belong[i] == br; i --) {
            int t = Query(l, r, a[i]);
            if(t > mx || t == mx && val[a[i]] < val[ret]) {
                mx = t, ret = a[i];
            }
        }
    }
    return val[ret];
}
void solve() {
    cin >> n;
    bSize = sqrt(n/(log(n)/log(2.0))), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), val.resize(n+1), va.resize(n+1), f.resize(bNum+1);
    for(auto &v : f) 
        v.resize(bNum+1);
    for(int i = 1; i <= n; i ++) {
        cin >> a[i];
        belong[i] = (i-1)/bSize + 1;
        if(!mp.count(a[i])) {
            mp[a[i]] = ++ nid;
            val[nid] = a[i];
        }
        a[i] = mp[a[i]];
        va[a[i]].push_back(i);
    }
    PrevCalc();
    int ans = 0;
    for(int i = 0; i < n; i ++) {
        int l, r;
        cin >> l >> r;
        // l = (l+ans-1) % n + 1, r = (r+ans-1) % n + 1;;
        if(l > r) swap(l, r);
        ans = Query(l, r);
        cout << ans << '\n';
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



### 做法2 - 普通莫队 + 值域分块

[数列分块入门 #9 莫队做法 - 316.2277 - 洛谷博客 (luogu.com.cn)](https://www.luogu.com.cn/blog/220037/SLFKRM9)

如果只考虑众数出现的次数，直接普通莫队维护`x出现的次数`和`出现了x次的数有多少个`就可以解决。

但现在需要输出具体的最小的数，可以用（次数）值域分块来找，用普通莫队维护$f[i, j]$，表示在第 i 个值块中恰出现 j 次的值的个数（和参考博客参数顺序不同），关于为什么是个数的话，还是为了在维护这个信息时，更加方便，其实只是为了判断是否存在恰好为 j 次的。

普通莫队维护了信息，一次查询需要$O(\sqrt{n})$

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

struct Rec {
    int l, r, qid;
};
int n, bSize, bNum, modecnt;
vector<int> a, belong, val, cnt, ccnt;
vector<vector<int>> f;
vector<Rec> query;

void add(int x) {
    x = a[x];
    int bx = belong[x], &c = cnt[x];
    ccnt[c] --;
    f[bx][c] --;
    c ++;
    if(modecnt < c) {
        modecnt = c;
    }
    ccnt[c] ++;
    f[bx][c] ++;
}
void del(int x) {
    x = a[x];
    int bx = belong[x], &c = cnt[x];
    ccnt[c] --;
    f[bx][c] --;
    if(modecnt == c && ccnt[c] == 0) {
        modecnt --;
    }
    c --;
    ccnt[c] ++;
    f[bx][c] ++;
}
int Query() {
    for(int i = 1; i <= bNum; i ++) {
        if(f[i][modecnt] > 0) {
            for(int j = (i-1)*bSize + 1; j <= min(i*bSize, n); j ++) {
                if(cnt[j] == modecnt) {
                    return val[j];
                }
            }
        }
    }
    return -1;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), val.resize(n+1), cnt.resize(n+1);
    ccnt.resize(n+1), query.resize(n), f.resize(bNum+1);
    for(auto &v : f) v.resize(n+1);
    for(int i = 1; i <= n; i ++) {
        cin >> a[i];
        belong[i] = (i-1)/bSize + 1;
        val[i] = a[i];
    }
    sort(1+all(val));
    val.resize(unique(1+all(val)) - val.begin());
    for(int i = 1; i <= n; i ++) {
        a[i] = lower_bound(1+all(val), a[i]) - val.begin();
    }
    for(int i = 0; i < n; i ++) {
        auto &[l, r, qid] = query[i];
        cin >> l >> r;
        qid = i;
    }
    sort(all(query), [&](const Rec &a, const Rec &b) {
        int abl = belong[a.l], bbl = belong[b.l];
        if(abl != bbl) {
            return abl < bbl;
        }
        else {
            if(abl & 1) return a.r < b.r;
            else return a.r > b.r;
        }
    });
    vector<int> ans(n);
    int l = 1, r = 0;
    for(int i = 0; i < n; i ++) {
        auto [ll, rr, qid] = query[i];
        while(l > ll) add(-- l);
        while(r < rr) add(++ r);
        while(l < ll) del(l ++);
        while(r > rr) del(r --);
        ans[qid] = Query();
    }
    for(auto x : ans) {
        cout << x << '\n';
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



### 做法3 - 回滚莫队

不删除莫队，状态/信息正常回滚，答案记录跳回。

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

struct Rec {
    int l, r, qid;
};
int n, bSize, bNum, modecnt, modecntB, res, resB;
vector<int> a, belong, val, cnt, tcnt;
vector<Rec> query;

int bf(int l, int r) {
    int ret = 0, mx = 0;
    tcnt.assign(n+1, 0);
    for(int i = l; i <= r; i ++) { // tcnt
        tcnt[a[i]] ++;
        if(tcnt[a[i]] > mx || tcnt[a[i]] == mx && a[i] < ret) {
            mx = tcnt[a[i]], ret = a[i];
        }
    }
    return val[ret];
}
void add(int x) {
    x = a[x];
    cnt[x] ++;
    if(cnt[x] > modecnt || cnt[x] == modecnt && x < res) {
        modecnt = cnt[x], res = x;
    }
}
void del(int x) {
    x = a[x];
    cnt[x] --;
}
void solve() {
    cin >> n;
    bSize = sqrt(n), bNum = (n-1)/bSize + 1;
    a.resize(n+1), belong.resize(n+1), val.resize(n+1);
    cnt.resize(n+1);
    for(int i = 1; i <= n; i ++) {
        cin >> a[i];
        belong[i] = (i-1)/bSize + 1;
        val[i] = a[i];
    }
    sort(1+all(val));
    val.resize(unique(1+all(val)) - val.begin());
    for(int i = 1; i <= n; i ++) {
        a[i] = lower_bound(1+all(val), a[i]) - val.begin();
    }
    query.resize(n);
    n = 0;
    for(auto &[l, r, qid] : query) {
        cin >> l >> r;
        qid = n ++;
    }
    sort(all(query), [&](const Rec &a, const Rec &b) {
        int abl = belong[a.l], bbl = belong[b.l];
        return abl == bbl ? a.r < b.r : abl < bbl;
    });

    vector<int> ans(n);
    for(int bid = 1, id = 0; bid <= bNum; bid ++) {
        int tp = min(bid*bSize, n), l = tp+1, r = tp;
        res = modecnt = 0;
        cnt.assign(n+1, 0);
        for( ; id < n && belong[query[id].l] == bid; id ++) {
            auto [ll, rr, qid] = query[id];
            int bll = belong[ll], brr = belong[rr];
            if(bll == brr) {
                ans[qid] = bf(ll, rr);
            }
            else {
                while(r < rr) add(++ r);
                modecntB = modecnt, resB = res;
                while(l > ll) add(-- l);
                ans[qid] = val[res];
                while(l < tp+1) del(l ++);
                modecnt = modecntB, res = resB;
            }
        }
    }
    for(auto x : ans) {
        cout << x << '\n';
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