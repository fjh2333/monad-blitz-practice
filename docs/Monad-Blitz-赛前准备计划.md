# Monad Blitz 赛前准备计划

活动：[Monad Blitz @惠州](https://luma.com/vw825phc)（1 天线下黑客松）
计划创建：2026-09-02
剩余时间：约 3 天
原则：**同一条流水线加深，不学后面的 DeFi / L2 / Solana。作业不追求做完，追求每件都亲手跑通。**

分工：**Bank 是健身房，不是参赛作品。** 现场产品用同一套技能（存状态、校验权限、发交易），换一个能讲 60 秒的故事。只有第 2 天 Bank 真的上链跑通，才允许进 `03-product/`。

---

## 0. 当前机器状态（2026-09-02 实测）

| 工具 | 状态 | 说明 |
|---|---|---|
| Git | 已有 | `git 2.50.1` |
| Node / npm | 已有 | `node v26.5.0` / `npm 11.17.0`，后面做前端才用 |
| Homebrew | 已有 | 装软件用 |
| Foundry（forge / cast / anvil） | **已安装 v1.8.1**（2026-09-02） | 满足 Monad 要求（≥1.8）。PATH 已写入 `~/.zshrc` |
| Viem | **不用「安装软件」** | 它是前端项目的 npm 依赖，做前端时再装 |
| 作业仓库本地副本 | 没有 | 需要时再 clone，先自己写 |
| 本工作区 | 已整理 | 见下方目录 |

练习用钱包：**不要用存真金的钱包。** 新建一个 MetaMask 账号专门练测试网。

### 目录约定（工程都放这里，不要散落）

根目录：`/Users/fjh/code/local/web3/monad-blitz`

| 路径 | 用途 | 你要做的 |
|---|---|---|
| `docs/` | 本计划 | 只改文档，不放合约 |
| `01-counter/` | 第 1 天练习 | 在**该文件夹内** `forge init . --no-commit` |
| `02-bank/` | 第 2 天练习 | 同上；这是技能课，不是产品 |
| `03-product/` | 第 3 天或赛前的 Demo 产品 | **过关后再** `forge init` |
| `secrets/` | 本地备忘 | 已 gitignore，禁止放私钥 |
| `README.md` | 目录说明 | — |

`forge init` 必须在对应子目录里执行。不要在根目录 init，否则练习、产品和文档会混在一起。

### 工具装在哪：电脑上，不是每个工程里各装一份

| | 装一次在哪 | 和 `01-counter` 的关系 |
|---|---|---|
| Foundry（`forge` / `cast` / `anvil`） | **整台电脑**（类似 Git、Node） | 所有练习工程共用。工程里只有你的合约代码 |
| Node / npm | **整台电脑**（你已经有） | 以后做前端时才用 |
| MetaMask | **浏览器** | 和文件夹无关 |
| Viem | **某个前端项目的** `node_modules` | 现在不要装。以后若做页面，才在那个前端目录 `npm install viem` |

整理文件夹的意思是：**练习代码分开放**，避免 Counter、Bank、产品混在一个 Foundry 项目里。  
不是让你在 `01-counter`、`02-bank` 里各装一次 Foundry。

---

## 1. 这些东西分别是什么（先建立正确心智模型）

它们都不是「打开就能点的 App」，而是开发工具。和 VS Code / MetaMask 那种带窗口的软件不一样。

### 1.1 整条流水线（三天只练这一条）

```
你写 Solidity
    → Foundry 编译、测试、签名、发交易
        → RPC（https://testnet-rpc.monad.xyz）
            → Monad 测试网节点
                → 链上出现合约 / 交易
                    → 浏览器（monadvision）能搜到
                    → MetaMask 能调它（这就是最简「前端」）
                    → 以后再用 Viem 在网页里调（可选）
```

### 1.2 Foundry 是什么

**智能合约的命令行工具箱**（Rust 写的），装好后终端里多出三个命令：

| 命令 | 干什么 | 类比 |
|---|---|---|
| `forge` | 建项目、编译、写测试、**部署合约** | 合约侧的编译器 + 测试器 + 部署器 |
| `cast` | 查余额、调合约、发一笔交易 | 终端里的小号钱包 |
| `anvil` | 在自己电脑起一条假链 | 本地沙盒，第 1 天可以不碰 |

所以：**Foundry 不是「只能部署」**，部署只是它的一部分。三天里你主要用 `forge`（写/测/部署）和偶尔用 `cast`（查一下链上结果）。

安装后不是出现一个图标，而是在终端输入 `forge --version` 有输出。官方文档要求 **v1.8+**，并在项目 `foundry.toml` 里加：

```toml
[profile.default]
network = "monad"
```

含义：本地测试尽量按 Monad 的 gas / 操作码规则跑，减少「本地能过、测试网失败」。

Monad 扣费和以太坊不同：**按你申报的 gas limit 全额扣，用不完也不退。** 测试币免费，先求发出去；不要把 gas limit 填成天文数字。细节现场用不到深挖。

### 1.3 Viem 是什么

**JavaScript/TypeScript 库**，用来在代码里跟链说话（读余额、调合约、听事件）。

- 不是单独软件，没有安装包图标
- 出现在前端项目里：`npm install viem`
- 作业仓库 `FrontEnd/viem-front` 就是用它写的页面

**三天内 Viem 是加分项，不是主线。** 没有网页也能 Demo：Remix 或 Foundry 部署后，用 MetaMask + 区块浏览器点交易，评委同样能看见「链上跑起来了」。

### 1.4 还需要哪些（第 1 天会用到）

| 东西 | 是什么 |
|---|---|
| MetaMask | 浏览器钱包插件，帮你保管测试网私钥、切到 Monad、点签名 |
| Chain ID `10143` | Monad 测试网的身份证，钱包和交易都必须带这个号 |
| `MON` | 测试网原生币，付手续费用，**没真金价值** |
| RPC | 你的电脑问节点的网址，钱包和 Foundry 都填它 |
| Faucet | 免费领测试 MON 的网页 |
| 区块浏览器 | 公开账本搜索：交易成没成、合约在哪 |
| Remix | 网页版 Solidity IDE，不会命令行时的备用部署方式 |

Remix 备用入口：官方有 [在 Remix 上部署到 Monad](https://docs.monad.xyz/guides/deploy-smart-contract/remix)。Foundry 卡死时用它，不要两条路同时学。

---

## 2. 作业怎么取舍（「多掌握」≠「全做一遍」）

课表模块 6 及以后（合约进阶、DeFi、TheGraph、L2、Solana）**全部跳过。**

模块 1–5 的作业很多，三天做不完。按「对这条流水线有没有用」分成三档。

对照：
- 课表：https://learnblockchain.cn/article/15587
- 作业：https://learnblockchain.cn/article/17585
- 参考仓库（先别抄）：https://github.com/fjh2333/Web3-BootCamp-Practice
- 笔记：`/Users/fjh/code/notes/web3/tiny熊教程`

### 必做（P0）—— 做不完就砍别的，这几件必须亲手跑通

| 顺序 | 作业 | 对应 | 三天后你要能 |
|---|---|---|---|
| 1 | 环境 + 第一个合约上 Monad | 模块一实战 4，换到 Monad | 浏览器里看到自己的合约 |
| 2 | 自己写 Bank（存/取 ETH，这里是 MON） | [Bank](https://decert.me/quests/c43324bc-0220-4e81-b533-668fa644c1c3) | 不看答案写出存、取、记账 |
| 3 | Foundry 测试 Bank | [测 Bank](https://decert.me/quests/b8cde6b2-bad4-4629-b73a-2d0dede4f347) | `forge test` 能过 |
| 4 | Foundry 部署到测试网 | [Foundry 部署](https://decert.me/quests/7bd246d8-f0c3-45c0-a335-766505afdba9) 的流程，RPC 换成 Monad | `forge script --broadcast` 成功 |

这 4 件其实是 **同一个 Bank 项目的 4 个深度**，不是 4 个无关作业。这就是「同一条流水线加深」。

### 停一下：Bank 当产品会不会太初级？

**会。** 当作第 2 天的实操课刚刚好；当作黑客松 Demo 则像交作业，评委很难记住。

一天赛真正加分的通常不是合约更复杂，而是：

1. 能讲清「谁、为什么、点哪三下」
2. 链上有一笔真实交易
3. 最好沾一点活动标签（AI + 链）

所以策略是：**技能用 Bank 练，作品用「Bank 同款复杂度 + 更好的故事」。** 不新开 DeFi / NFT 市场 / 跨链。

默认推荐产品（过关后进 `03-product/`）：**HackCheck 学习打卡证明**

| | Bank（练习） | HackCheck（产品） |
|---|---|---|
| 链上动作 | 存款 / 取款 | 打卡 / 查记录 /（可选）铸造完成证明 |
| Solidity 难度 | mapping + 权限 | 几乎一样，多一个 `string` 或计数 |
| Demo 时评委看到 | 「我会写作业」 | 「用户今天学了什么，链上留下证明」 |
| 和 AI 的接点 | 几乎没有 | 现场让 AI 生成一句评语，再上链 |

合约建议就这几个函数，不要再加：

- `checkIn(string memory note)`：每个地址每天一次（或总共一次，更简单）
- `getCheckIn(address)`：查看
- 可选：打卡满 N 次 `mint` 一个徽章 NFT（仅当第 2 天非常顺）

现场 60 秒讲词示例：「黑客松现场容易说自己做了很多，但没有记录。用户连钱包，写一句今天的进展（或让 AI 生成评语），上链。Monad 出块快，适合这种高频小交易。」

**不要做的产品：** 原样 Bank/ATM、无前端的纯 ERC20、NFT 市场、DEX。  
**不要提前写产品：** 没在 Monad 上完成存取之前，写 HackCheck 等于同时学两份合约，会消化不良。

### 有余力再做（P1）—— 第 2 天下午或第 3 天最多选 1 件

按对黑客松的性价比排序，**只选一件，不要并行：**

1. **TokenBank（ERC20 存取）** — 作业 [ERC20](https://decert.me/quests/aa45f136-27a3-4bc9-b4f7-15308e1e0daa) + [TokenBank](https://decert.me/quests/eeb9f7d8-6fd0-4c38-b09c-75a29bd53af3)  
   理由：Bank 的升级版，现场最容易改成「积分/代金券」故事。
2. **最简前端** — [Viem 给 TokenBank 做页面](https://decert.me/quests/56e455b3-901c-415d-90c0-a20759469cf9) 或 [AppKit 登录](https://decert.me/quests/a1a9aff6-1788-4254-bc47-405cc529bbd1)  
   理由：Demo 更好看。卡住超过 2 小时就停，回退到 MetaMask 直接调合约。
3. **BigBank** — [继承/接口](https://decert.me/quests/063c14be-d3e6-41e0-a243-54e35b1dde58)  
   理由：巩固 Solidity，但对 Demo 帮助小于 TokenBank。

### 明确先不做（P2）—— 想「都掌握」时看到也跳过

| 作业 | 为什么现在不做 |
|---|---|
| POW / 最小区块链模拟 | 已有笔记即可，与部署无关 |
| ABI / call / delegatecall 练习 | 概念课，不增加 Demo 能力 |
| ERC721 / NFTMarket | 一天赛做不完市场；真要 NFT 现场用 OZ 模板 20 分钟能铸 |
| Foundry 模糊测试 / 不变量 | Bank 的普通 test 够用 |
| 命令行钱包 / 交易所扫块 / 多签 | 模块五后半，超出三天 |
| Permit / Permit2 / Merkle / 升级合约 | 加分项，现场来不及 |
| 仓库后半：LaunchPad、闪电贷、质押、杠杆、DAO、Solana | 已约定不学 |

**「多学一点」的正确姿势：** Bank 自己写完 → 再自己部署第二遍 → 再给它加一个 view（例如最高存款人）→ 再给评委讲 60 秒。  
这比新开 5 个作业更像「掌握」。

---

## 3. 三天日程（每天必须留下链上证据）

验收标准只有一条：**区块浏览器里有你的交易。** 看懂笔记不算完成。

每天建议 3–5 小时。超时就停在当天的「最低完成线」，不要欠债到第二天又开新题。

### 第 1 天：环境 + 第一次上链

**最低完成线：** MetaMask 有 MON + 一个合约出现在 MonadVision。

1. Chrome 安装 MetaMask，**新建账号**（只用于测试网）。
2. 添加网络：
   - 网络名：`Monad Testnet`
   - RPC：`https://testnet-rpc.monad.xyz`
   - Chain ID：`10143`
   - 符号：`MON`
   - 浏览器：`https://testnet.monadvision.com`
3. 打开 https://faucet.monad.xyz 领测试 MON，钱包能看到余额。
4. 安装 Foundry：

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
forge --version   # 需要 1.8 或更高
```

若终端找不到 `foundryup` / `forge`，按安装脚本提示把 `~/.foundry/bin` 加进 PATH，然后新开一个终端再试。

5. **进入 `01-counter/` 再建项目**（不要在仓库根目录 `forge init`，不要一上来写 Bank）：

```bash
cd "/Users/fjh/code/local/web3/monad-blitz/01-counter"
forge init . --no-commit
```

在生成的 `foundry.toml` 的 `[profile.default]` 下增加一行：`network = "monad"`。

6. 用模板自带的 `Counter`（或笔记里那个 `count()`）走通：

```bash
forge build
forge test --network monad
```

7. 部署（先模拟，再真发）。**私钥只放在终端本地，不要写入这个仓库、不要发给任何人。**

```bash
# 先模拟，不花钱
forge script script/Counter.s.sol --rpc-url https://testnet-rpc.monad.xyz --private-key $PRIVATE_KEY

# 确认无误再广播
forge script script/Counter.s.sol --rpc-url https://testnet-rpc.monad.xyz --private-key $PRIVATE_KEY --broadcast
```

私钥从 MetaMask「账号详情 → 导出私钥」复制。命令跑完后不要把密钥留在 shell 历史里展示给别人。更稳妥的做法是用 Foundry keystore（`cast wallet import`），第 1 天若来不及，用环境变量也可以：

```bash
export PRIVATE_KEY=0x你的私钥
```

8. 把终端打印的合约地址贴进 https://testnet.monadvision.com 。看得到 = 第 1 天完成。
9. 可选：`cast send` 或 Remix 调一次 `number` / `increment`，浏览器里出现第二笔交易。

**今天不要写 Bank，不要碰前端。**

卡住时的降级：Foundry 安装失败 → 改用 Remix 部署 Counter，第 2 天再回来装 Foundry。不要当天死磕安装超过 1.5 小时。

官方参考：
- 网络信息：https://docs.monad.xyz/developer-essentials/testnet
- Foundry：https://docs.monad.xyz/tooling-and-infra/toolkits/foundry
- 部署指南：https://docs.monad.xyz/guides/deploy-smart-contract

---

### 第 2 天：自己写 Bank，测完再部署

**最低完成线：** 自己写的 Bank 在 Monad 上能存、能取，浏览器能证明。

Bank 只要这些能力（和作业一致，这里的 ETH 在 Monad 上就是 MON）：

- 合约能收款（`receive` / `deposit`）
- `mapping` 记下每人存了多少
- `withdraw` 取回自己的
- 不能取别人的

先建项目（仍在 `02-bank/` 内）：

```bash
cd "/Users/fjh/code/local/web3/monad-blitz/02-bank"
forge init . --no-commit
```

同样在 `foundry.toml` 加上 `network = "monad"`。

顺序（重要）：

1. **合上参考仓库，自己写** `src/Bank.sol`。写不出再看笔记《2-solidity特性》。
2. 写 `test/Bank.t.sol`：存、取、别人不能取。`forge test --network monad`。
3. 写 `script/DeployBank.s.sol`，先模拟再 `--broadcast`。
4. MetaMask 往合约地址转一笔很小的 MON（或调用 `deposit`），再 `withdraw`，浏览器核对。

写完若还有时间（仍在第 2 天），只加 **一个** 小功能，例如：

- `getTopDepositor()` 返回当前存款最多的地址  
或
- 记录存款次数  

用来 Demo 时多一句话，不要新开 TokenBank。

**今天不要做前端、不要做 NFT、不要开始写 HackCheck。** 过关标准见第 2 天打卡；没勾完就还在健身房。

实在写不出时：打开仓库 `BankSmartContract` **对照差异**，然后关掉，再自己重写一遍。抄一遍提交 ≠ 掌握。

---

### 第 3 天（活动前一天）：按第 2 天结果分支，不要两头押

先看第 2 天打卡。**没勾完「自己写的 Bank 已在测试网存过、取过」→ 走分支 A，禁止开 `03-product/`。**

#### 分支 A：第 2 天吃力（完全合理）

现场用 Bank 改个名字也能交差（小费罐 / 活动存款），但竞争力弱。第 3 天只做：

1. 把 Bank 再部署一遍
2. 备好地址、交易链接、60 秒讲词
3. 早休息

不要因为焦虑去学 TokenBank 或前端。

#### 分支 B：第 2 天已过关（推荐走这里）

上午在 `03-product/` 写 **HackCheck**（函数列表见上文），测完部署到 Monad。  
下午二选一，卡住 2 小时就停：

- 给 HackCheck 接三个按钮的最小页面（连接 / 打卡 / 查看）
- 或仍用 MetaMask 调合约，把时间花在讲词和「AI 生成一句评语再粘贴上链」的演示流程

**不要**再开 TokenBank 当第三条线。TokenBank 只作为「若 HackCheck 写崩了」的退路，优先退回已经能跑的 Bank。

晚上不要加功能。准备：演示账号留一点 MON、合约地址、现场网卡时的截图。

---

## 4. 现场怎么用这三天的成果

上午 Workshop 即使你会部署，也跟着做，用来问 DevRel RPC / 验证问题。

下午 6.5 小时建议：

1. 先定 scope（写在纸上）：用户点什么按钮、链上记什么、评委看哪三下。
2. 若 `03-product/` 已有 HackCheck：只改文案和演示数据，不改架构。若只有 Bank：改名叫小费罐/签到金库，把故事讲清楚，仍争取 18:00 前有新交易。
3. 18:00 前必须有一笔新的链上交易。UI 丑没有关系。
4. AI 部分现场用 Cursor 生成评语/页面即可；**链和钱包必须这三天自己踩过坑。**

不要现场做：DEX、借贷、跨链、账号抽象、训练模型。

组队：你扛合约 + 部署；有人会前端更好。一个人用 Remix/MetaMask 也能 Demo。

---

## 5. 每天打卡（完成后自己勾）

### 第 1 天（工作目录：`01-counter/`）— ✅ 2026-09-02 完成

- [x] MetaMask 新账号，已切到 Monad Testnet（10143）
- [x] 水龙头领到 MON（10 MON）
- [x] `forge --version` ≥ 1.8（1.8.1）
- [x] 在 `01-counter/` 内完成 `forge init . --no-commit`（不是仓库根目录）
- [x] `foundry.toml` 有 `network = "monad"`
- [x] Counter 地址能在 MonadVision 打开（`0x0b8Bbf9856dFFFcd4d7c975aef878C4a1e423CA4`）
- [x] 调过一次合约函数，浏览器有第二笔交易（`cast send increment()` + `cast call number()` 返回 1）

### 第 2 天（工作目录：`02-bank/`）— ✅ 2026-09-03 完成

- [x] 在 `02-bank/` 内 `forge init`
- [x] 自己写的 `Bank.sol`（不是只复制仓库）
- [x] `forge test` 通过（3 passed：存、取、不能取别人的）
- [x] Bank 已部署到 Monad Testnet（`0x16C929794d75e288949fb0F77d36123d239e77bA`）
- [x] 用钱包真实存过（0.1 MON）、取过（0.05 MON），浏览器能证明
- [x] **以上全勾完，可以进入 `03-product/`**

### 第 3 天

- [ ] 分支 A 或 B 只选一条，没有两边同时做
- [ ] 不看教程能再部署一次（Bank 或 HackCheck）
- [ ] 合约地址 + 交易链接已备好
- [ ] 60 秒讲词说过一遍（故事不是「这是一个银行作业」）

---

## 6. 私钥与安全（写在计划里是为了你真的遵守）

- 测试账号也可以被盗。私钥 = 这个地址的全部控制权。
- 不要把私钥写进 `md`、不要 commit、不要发到聊天里。
- 演示用测试账号；真钱钱包不要导入这台练习流程。

---

## 7. 下一步（由你独立完成，卡住把报错贴回来）

实操你来做。我这边只辅助：解释报错、看命令该不该用、不代替你敲。

不要再加新文档、不要先 clone 全部作业。打开**你自己的终端**，按顺序：

**步骤 A — 安装 Foundry**

```bash
curl -L https://foundry.paradigm.xyz | bash
```

装完后按脚本提示：把 Foundry 加入 PATH（常见是新开一个终端，或 `source ~/.zshrc`）。然后：

```bash
foundryup
forge --version
```

需要看到 **0.8 / 1.8 或更高**（`forge --version` 会打印类似 `forge Version: 1.8.x`）。若提示找不到 `foundryup` 或 `forge`，把完整报错发我，先不要装别的东西。

**步骤 B — 仅当 A 成功后，在指定文件夹 init**

```bash
cd "/Users/fjh/code/local/web3/monad-blitz/01-counter"
forge init . --no-commit
ls
```

你应看到 `src/`、`test/`、`script/`、`foundry.toml`。若问是否覆盖已有 README，选覆盖或先把 README 拷走都行，该文件夹里现在只有说明文件。

**步骤 C — 改配置并编译**

编辑 `01-counter/foundry.toml`，在 `[profile.default]` 下加 `network = "monad"`，然后：

```bash
forge build
forge test --network monad
```

到这里就可以按第 1 天后面步骤去配钱包和部署。私钥不要发给我。

卡在某一步时，把**终端原文**发回来，比换题目更有用。
