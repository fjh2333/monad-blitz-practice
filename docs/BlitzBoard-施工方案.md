# Blitz Board 施工方案（审计稿，未开工）

状态：**拍板已部分确认，待「按方案开工」才写代码**  
日期：黑客松当日  
原则：6.5 小时必须能公网 Demo；完整国际象棋是 **v2 升级路径**，不是今天的交付。

已确认（2026-09-05 现场）：

| 项 | 你的决定 |
|---|---|
| 棋盘 | 5×5 |
| 奖杯 NFT | **要** |
| 超时 180s | **要**（见下：超时 = 当前行棋方判负，对方获胜） |
| 公网 | GitHub Pages，路径 `/docs/play` |

---

## 0. 拍板结论（先读这一节）

| 项 | 决定 |
|---|---|
| 产品名 | Blitz Board |
| 今天做 | 5×5 迷你棋（Gardner 变体），链上裁判走子 + 多桌并行 |
| 今天不做 | 8×8 完整规则、AI 对战、押注/发币赌输赢、观战大厅、精致 UI |
| AI（开发） | 本助手写代码（主办方要求） |
| AI（产品 P2） | 走子后「评棋解说」：核心闭环 + 公网 URL 之后才加；API 失败必须仍能下棋 |
| 交付 | Monad Testnet 合约 + GitHub Pages 公网 URL + 胜者 NFT |
| 升级 | v2 = 完整 8×8 规则；v3 = AI 对战 + 质押赌局（见第 3.3 节） |

你确认本文件后，才允许进入 `04-blitz-board/` 写代码。

---

## 1. 产品一句话

两人各连钱包，在 Monad 上下一盘 **5×5 闪电棋**；每步一笔交易；吃掉对方王即胜，铸一枚奖杯 NFT。多桌互不共享棋盘，用来讲 **Monad 出块快 + 并行执行互不冲突的 storage**。

现场 60 秒：

> 完整象棋规则引擎 6 小时做不完。我们把棋盘收成 5×5，走子上链、多桌并行。Monad 按 gas limit 收费且出块快，适合这种高频小交易。规则模块今天是迷你棋，存储按 8×8 打包，以后可以升级成完整国际象棋而不改对局账本。

---

## 2. 和现场 PPT 对齐

| PPT 要求 | 本方案 |
|---|---|
| 新颖机制 | 链上迷你棋 + 多桌并行，不是 Bank/HackCheck 改皮 |
| 探索 Monad | 高频 `move`、多 `gameId` 独立 slot、limit 精算 |
| 新方式解决问题 | 「先可玩的链上棋，再长成完整象棋」而不是一次做 8×8 |
| 少操心 UI | Unicode 棋子 + 5×5 格子，不画皮肤 |
| 少操心功能清单 | 见第 7 节砍单顺序 |
| 公网 URL | GitHub Pages，禁止 localhost Demo |

---

## 3. 范围：今天 vs 升级完整象棋

### 3.1 今天（v1）规则 — Gardner 5×5

棋盘：文件 a–e，行 1–5。开局（白在下方）：

```
5  r n b q k     （黑）
4  p p p p p
3  . . . . .
2  P P P P P
1  R N B Q K     （白）
   a b c d e
```

棋子走法（标准几何，棋盘更小）：

- 兵：前进一步；斜吃；**无**两步、**无**吃过路兵；到底线升后（只升后，简化）
- 马：日字；越子
- 象/车/后：滑行直到受阻
- 王：邻格

胜负（v1 刻意简化，这是能做完的关键）：

- **吃掉对方的王 → 胜**（不实现将军/将死/逼和搜索）
- 超时未走（如 3 分钟）对方可 `claimTimeout` 取胜
- **超时 180s = 当前行棋方判负**：对方调 `claimTimeout()` 取胜并 mint（不是平局、也不是自动弹窗）
- 任一方可 `resign()`：**自己认输**，对方获胜（不是双方都要点头）

**明确不做（v1）：** 王车易位、吃过路兵、将军检测、将死、逼和、三次重复、50 步、长将判定。

### 3.2 v2 完整国际象棋 — 预留，不在今天做

升级时 **不改** `Game.board` 的打包方式（见第 5 节）：64 格 × 4 bit 从第一天就按 8×8 槽位存，v1 只用 a1–e5，其余格恒为空且禁止落入。

v2 模块替换清单：

| 模块 | v1 | v2 |
|---|---|---|
| `LibBoard` | 合法格 = 5×5 掩码 | 掩码改 8×8 |
| `LibMoves` | 迷你走法 | 标准走法 + 双步兵 + 升变多选择 |
| `LibCheck` | 不存在 | 走后己王不可被将 |
| `LibCastleEP` | 不存在 | 易位权 bit + en passant 格 |
| 终局 | 吃王 / 超时 / 认输 | 将死 / 逼和 / 重复 / 50 步 |

工程上：v1 就把 `LibBoard` / `LibMoves` / `GameCore` 拆开，避免所有逻辑写进一个 800 行合约导致 v2 无法插模块。

### 3.3 v3 预留：AI 对战 + 质押赌输赢（今天明确不做）

想法：让两个 AI（或人机）对弈，用户用 MON 或自发行代币押哪边赢。

**今天不做的原因（审计）：**

| 坑 | 说明 |
|---|---|
| 谁在链上「走棋」 | 模型在链下。必须有人把走法提交上链，否则合约不知道发生了什么 |
| 信任 | 提交者可以改 AI 的棋。要公平，需要预言机 / 多人提交 / commit-reveal，工作量 ≈ 再做一个产品 |
| 资金盘 | 质押 + 结算 = Bank 权限 + 终局争议 + 退款。Monad 测试网 MON 无真金，但评委仍会问「谁能把池子提走」 |
| 发币赌 | 再部署 ERC20 + 奖池，和棋引擎抢同一下午 |
| 监管观感 | 「赌博」叙事现场可能被主办方皱眉；讲「观战预测」也改变不了实现复杂度 |

**以后若做，插在 v1/v2 之上，不改棋盘 packing：**

1. `Game` 已有终局 winner → 结算合约只读 `status/winner`，不重写走子
2. 押注用独立 `StakePool.sol`：`bet(gameId, side)` + `claim(gameId)`，奖池按 winner 分
3. AI 对局：后端或前端循环 `engine.bestMove` → `move()`，私钥是「机器人 EOA」，不是把模型放进 Solidity
4. 公平性 v3.1 再加：双机器人地址公开、每步 event 可回放，不假装「AI 无法作恶」

一句话：赌局是**产品故事**，不是 6.5 小时的第一刀。先有可信的链上棋，才有东西可赌。

### 3.4 P2：评棋解说（你已同意：核心之后、可砍）

- 时机：公网能下棋、吃王能结束之后
- 做什么：`move` 确认后，前端把棋盘文本 POST 给一个模型 API，页面显示一句解说
- 降级：超时/401/断网 → 显示「解说暂不可用」，**绝不挡住走子**
- 预计：密钥和网络顺 30–45 分钟；不顺 1.5–2 小时则砍
- 合约零改动

---

## 4. 架构

```
04-blitz-board/
  src/
    BlitzBoard.sol      对外：create / join / move / resign / claimTimeout
    （不单独 Trophy.sol）BlitzBoard is ERC721，tokenId = gameId
    lib/
      LibBoard.sol      打包/解包、5×5 掩码
      LibMoves.sol      走子合法性（无将军）
  test/                 走子、吃王、超时、不能重入已结束对局
  script/Deploy.s.sol
  frontend/             静态页，构建后拷到 docs/play/ 供 GitHub Pages
docs/play/index.html    公网站点（Pages source = /docs）
```

合约调用流：

```
create() → gameId, 白方 = msg.sender, 棋盘 = 开局编码
join(gameId) → 黑方 = msg.sender, status = Active
move(gameId, from, to)
    校验：轮到你、格子在 5×5、走法合法、非空、不吃己方
    写 board、换边、lastMoveAt = block.timestamp
    若目标格是对方王 → status = Win、_mint(winner)
claimTimeout / resign → 终局 + mint
```

前端三下（评委路径）：

1. Connect（自动切 Chain 10143）
2. Create 或 Join（可用输入框填 gameId）
3. 点格子走子 → 等确认 → 棋盘刷新；吃王后页面显示奖杯 tokenId

公网 URL（评委打开这个，不是 localhost）：

`https://fjh2333.github.io/monad-blitz-practice/play/`

**GitHub Pages 不是「在手机上改设置」。**

| | 做什么 | 在哪 |
|---|---|---|
| 一次配置 | 仓库 Settings → Pages → Source = `main` 分支、文件夹 `/docs` | **电脑浏览器**登录 GitHub 点一次即可 |
| 以后每次 | `git push` 后等 1～2 分钟，Pages 自动更新 | 不用再进设置 |
| 手机 | **只用来打开上面的 URL 验公网**（评委/自己用流量测），不是去改 Pages 设置 | 可选；电脑无痕窗口也能验 |

你不必提前练 Pages。开工后我写 `docs/play/index.html` 并 push，你在电脑打开仓库设置勾一次。勾之前 URL 404 是正常的。

---

## 5. 存储与 gas 设计（Monad：按 gas **limit** 收费）

### 5.1 棋盘打包（为 8×8 预留）

- 每格 4 bit：`0 空，1–6 白兵马象车后王，7–12 黑`
- 64 格 × 4 bit = **恰好 256 bit = 一个 `uint256 board`**
- v1 只使用 squareId = `file + rank*8`，其中 `file<5 && rank<5`；其余格必须为 0
- 走子参数：`uint8 from, uint8 to`（0–63），不用 `string "e2e4"`（贵、还要解析）

### 5.2 Game 结构（目标 ≤ 5 个 slot）

```text
slot0: board           uint256
slot1: white           address
slot2: black           address
slot3: packed          lastMoveAt uint32 | moveCount uint16 | status uint8 | toMove uint8
```

对局历史 **不上 storage**：`event Move(uint256 indexed gameId, uint8 from, uint8 to, uint8 piece)`。前端用 `eth_getLogs` 回放。这是相对 HackCheck 里 `CheckIn[]` 无限 push 的核心省 gas 点。

### 5.3 前端 gas limit

- `const gas = await contract.move.estimateGas(...)`
- `tx = await contract.move(..., { gasLimit: gas * 115n / 100n })`
- **禁止**写死 `500000`
- 说明：Monad 收的是 limit 不是 used；limit 开大等于多付钱

### 5.4 其它

- 入参 `uint8` / `calldata` 事件字符串不要
- NFT 用 `_mint` 不用 `_safeMint`（便宜；奖杯给 EOA 即可）
- `create` 不要循环清棋盘：开局常量 `uint256 OPENING` 一次写入

---

## 6. 安全审计（开工前清单）

| ID | 风险 | v1 处理 |
|---|---|---|
| A1 | 自己 join 自己的局 | `require(msg.sender != white)` |
| A2 | 未加入就 move | `require(msg.sender == 轮到的那一方地址)` |
| A3 | 终局后仍 move/mint | `require(status == Active)`；mint 前把 status 写成终局（CEI） |
| A4 | 重复 mint | 终局状态机只进不出；`istoken` 不需要，status 已防 |
| A5 | from/to 越出 5×5 但落入预留 8×8 格 | `LibBoard.inPlay(sq)` 掩码，禁止 |
| A6 | 滑行越子 | `LibMoves` 射线逐步检查空格；**遇到 `!inPlay` 必须停**（预留的 8×8 空格不能当走廊绕过去） |
| A7 | 超时抢先 | `claimTimeout` 要求 `block.timestamp >= lastMoveAt + TIMEOUT`；TIMEOUT 常量 180s |
| A8 | 重入 mint | 先改 status 再 `_mint`；Trophy 无回调则风险低 |
| A9 | 创建者永不 join 占坑 | 可不处理（Demo 无经济）；可选 `cancel` 若 black==0 |
| A10 | 前端 ABI 与 packed mapping | 对局用 struct getter；棋盘用 `board(gameId)` 自己解码 |
| A11 | Pages 仍指向旧合约 | `index.html` 一个 `CONTRACT_ADDRESS` 常量，部署后只改这一处 |
| A12 | 私钥进前端 | 前端只用 MetaMask，无 PRIVATE_KEY |
| A13 | v2 升级误改 packing | 本文件冻结：4 bit/格、file+rank*8；v2 禁改 |

**接受的已知简化（要写进 README，避免被问倒）：**

- 不检测「送王」。可以走出被吃的一步，对方吃王即胜。这是 v1 裁判能力边界，v2 用 `LibCheck` 补。
- 兵升变只变后。
- 无和棋（除非双方都超时——不做双超时和，超时判负即可）。

---

## 7. 6.5 小时施工顺序（你确认后执行）

砍单顺序（超时从下往上砍）：评棋解说 → 超时判负 → 升变 → 奖杯 NFT → 棋盘好看 → **底线：create/join/move/吃王 + 公网能打开**。

禁止今天开工的：AI 对战循环、StakePool、ERC20 奖池。

| 时段 | 交付物 | 停手标准 |
|---|---|---|
| 0.5h | Foundry 工程 + `LibBoard` 编解码单测 | 编解码 roundtrip 过 |
| 1.5h | `LibMoves` + `move` 吃王测试 | 兵/马/车/王 各 1 个测试绿 |
| 0.5h | 部署测试网，记下地址 | MonadVision 能打开 |
| 1.5h | 静态棋盘页：连钱包、创建、走子 | **你**用真钱包走通 3 步 |
| 0.5h | 拷到 `docs/play/`，开 GitHub Pages | 手机流量打开公网 URL |
| 1h | 奖杯 NFT + 超时（能砍） | MetaMask 能看到 NFT 更好 |
| 最后 | 停功能，只修「演示会死」 | 60 秒讲词 + 备用截图 |

并行禁忌：不要同时做 v2 规则、排行榜、观战、第二套 UI。

---

## 8. 你怎么参与（不是手搓主路径）

1. 确认或驳回本方案（尤其：吃王即胜、5×5、不接产品 AI）
2. 部署时在你电脑 `export PRIVATE_KEY`（我不能也不该长期拿私钥）
3. 真钱包走子、开公网 URL、看 NFT
4. 审阅 PR 式 diff：构造函数、状态机、`inPlay` 掩码

---

## 9. 拍板状态

1. 5×5 + 吃王即胜 + 无将军 — **已接受**
2. 奖杯 NFT — **要**（`BlitzBoard is ERC721`，一次部署）
3. 超时 180s — **要** = 当前行棋方超时则判负，对手 `claimTimeout` 获胜
4. GitHub Pages — **要**；你电脑勾一次设置即可，手机只测 URL

**你回「按方案开工」之前，不创建 `04-blitz-board`、不写 Solidity。**

---

## 10. 第二轮审计：方案是否合理、还缺什么

### 10.1 总评：合理，适合今天开工

和现场 PPT、你的技能、6.5 小时是匹配的：

- 机制不是作业改皮，又能讲 Monad（高频小交易 + 多桌独立 storage）
- 规则砍到「吃王即胜」，你不会下完整象棋也不挡 Demo
- 存储按 8×8 预留，故事完整（v2/v3 有地方接）
- 公网路径具体，gas 约束写死了
- NFT 你刚做过，复用 OZ 继承

主要剩余风险不是「设计错」，而是 **LibMoves 写慢** 和 **双钱包 Demo 现场手忙脚乱**。下面补硬缺口。

### 10.2 已拍板但方案里原先含糊、现已钉死

| 缺口 | 钉死 |
|---|---|
| NFT 一份还是两份合约 | **BlitzBoard is ERC721**，`_mint(winner, gameId)`，不单独 Trophy.sol |
| resign | 单方认输，不是双方确认 |
| 超时语义 | 当前 `toMove` 超时 → 对方赢 |
| Pages | 电脑设置一次；手机只打开公网 URL |

### 10.3 实现时必须遵守的额外审计（否则会出 bug）

| ID | 问题 | 规定 |
|---|---|---|
| A14 | 5×5 嵌在 8×8 里，象/车/后可能沿「盘外空格」绕行 | 射线下一步若 `!inPlay`，视为墙，**不能**当空格继续 |
| A15 | Demo 只有一个 MetaMask | 准备 **两个账户**（你已有练习号，再临时建一个）；同一浏览器切换账户 Join。讲稿写死 6～8 步吃王剧本，不对即兴对局 |
| A16 | 5×5 正常对局可能很长，评委不等 | 剧本从开局走向「白吃黑王」；不要求一盘好看的棋 |
| A17 | `create` 后评委看不到 id | 前端必须大号显示 `gameId`，Join 输入框预填 |
| A18 | 切账户后面板状态错乱 | `accountsChanged` 时重读 `white/black/toMove` |
| A19 | NFT 无 metadata | 接受 MetaMask 只显示合约名 + tokenId；不花时间做图片 URI |
| A20 | `LibMoves` 时间盒 | 测试优先：兵前进一步、兵斜吃、马、车受阻、王邻格、吃王终局。象/后有 1 个斜线用例即可。超时则象/后走法用「复用车的射线 + 斜向」同一函数 |
| A21 | `join` 后才 Active | `create` 时 status=Waiting，未 join 禁止 `move` |
| A22 | 超时从何时计 | `join` 成功时写 `lastMoveAt`；其后每次 `move` 刷新。Waiting 局不能 `claimTimeout` |
| A23 | 工程嵌套 `.git` | `forge init` 后立刻删 `04-blitz-board/.git`，沿用仓库根 git |
| A24 | OZ 路径 | 从 `03-product/lib/openzeppelin-contracts` 复制或 `forge install --no-commit`；`.gitignore` 继续忽略 `lib/` |
| A25 | Pages 与 md 文档同目录 | 评委打开 `/play/` 即可；方案 md 被 Pages 公开无妨 |

### 10.4 仍接受的不完美（不要为它们开工加功能）

- 无将军：可以送王
- 无和棋
- 兵只升后
- 无观战大厅（别人可只读 `board(gameId)`，前端不做观众模式）
- 无 AI 解说直到 P2；无押注

### 10.5 时间是否够

底线（create/join/move/吃王 + Pages）按施工表 **约 4.5h**，剩 2h 给 NFT + 超时 + 修演示。NFT 你明确要，排在公网之后做也可以：先公网能下，再部署带 ERC721 的同一合约（**若先部署无 NFT 版再加继承，必须二次部署换地址**）。为避免换地址，**第一次部署就带 ERC721**，测试先写吃王 mint 一条即可。

### 10.6 结论

方案可以开工，没有必须再改主题的缺陷。你现在只差一句 **「按方案开工」**。发出前若还想改（例如先不要超时），直接说；不说就按本节钉死的执行。
