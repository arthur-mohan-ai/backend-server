# 数据模型

数据库：PostgreSQL（Neon）。本文件描述表结构，最终以迁移文件为准。

约定：

- 所有 ID 用 `BIGINT GENERATED ALWAYS AS IDENTITY`，由数据库自动递增生成；指向它的外键同样用 `BIGINT`。
- 金额一律用整数存，单位是分（cents）。
- 时间一律用 `TIMESTAMPTZ`（带时区）。时区用 IANA 名称存，例如 `'America/Denver'`。
- 文件只存 R2 上的对象路径（key），不存公开链接。原图只在付款后通过后端生成的临时链接下载。
- 字段名用完整单词，不用缩写。
- 表按依赖顺序排列：被引用的表写在前面。

## users

所有用户共用一张表，不区分买家和摄影师。

```sql
CREATE TABLE users (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,            -- 只存哈希，绝不存明文；如果采用 Better Auth，此表以它的结构为准
    username      TEXT NOT NULL UNIQUE,
    avatar_key    TEXT,                     -- 新注册用户可以没有头像
    timezone      TEXT NOT NULL,            -- IANA 时区名，如 'Asia/Taipei'
    country_code  CHAR(2) NOT NULL,         -- ISO 3166-1 两位代码，如 'US'、'TW'
    bio           TEXT,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## photographers

开通了摄影师资格的用户才有一行记录，和 users 是一对一关系。

```sql
CREATE TABLE photographers (
    user_id           BIGINT PRIMARY KEY REFERENCES users(id),
    status            TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending', 'approved', 'suspended')),
    stripe_account_id TEXT UNIQUE,          -- 完成收款开户后才有，所以允许为空
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## resorts

```sql
CREATE TABLE resorts (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE,
    logo_key     TEXT,
    timezone     TEXT NOT NULL,             -- 如 'America/Denver'
    country_code CHAR(2) NOT NULL
);
```

## photographer_resorts

摄影师和雪场之间的多对多关系。每一行代表一段合作关系。

```sql
CREATE TABLE photographer_resorts (
    photographer_id BIGINT NOT NULL REFERENCES photographers(user_id),
    resort_id       BIGINT NOT NULL REFERENCES resorts(id),
    status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'suspended')),
    PRIMARY KEY (photographer_id, resort_id)
);
```

## media

照片和视频。

```sql
CREATE TABLE media (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    photographer_id BIGINT NOT NULL REFERENCES photographers(user_id),
    resort_id       BIGINT NOT NULL REFERENCES resorts(id),
    customer_id     BIGINT REFERENCES users(id),   -- 已知被拍者时填写（marketplace 预约）；B2B2C 下为空
    type            TEXT NOT NULL CHECK (type IN ('image', 'video')),
    status          TEXT NOT NULL DEFAULT 'processing'
                    CHECK (status IN ('processing', 'ready', 'failed')),
    width           INTEGER CHECK (width > 0),     -- 处理完成后填入
    height          INTEGER CHECK (height > 0),
    price_cents     INTEGER NOT NULL CHECK (price_cents >= 0),  -- 暂按单张定价，见待定问题
    captured_at     TIMESTAMPTZ NOT NULL,
    original_key    TEXT NOT NULL,
    preview_key     TEXT,                          -- 带水印的预览图，处理完成后生成
    thumbnail_key   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 滑雪者按“雪场 + 时间段”找照片，是最常用的查询
CREATE INDEX media_resort_captured_idx ON media (resort_id, captured_at);
```

## orders

一个订单只包含同一个摄影师的作品，方便给摄影师分账。

```sql
CREATE TABLE orders (
    id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id        BIGINT NOT NULL REFERENCES users(id),
    photographer_id    BIGINT NOT NULL REFERENCES photographers(user_id),
    status             TEXT NOT NULL DEFAULT 'pending'
                       CHECK (status IN ('pending', 'paid', 'refunded', 'cancelled')),
    amount_cents       INTEGER NOT NULL CHECK (amount_cents > 0),
    platform_fee_cents INTEGER NOT NULL
                       CHECK (platform_fee_cents >= 0 AND platform_fee_cents <= amount_cents),
    payment_ref        TEXT UNIQUE,     -- 支付服务的交易编号，发起付款后才有
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## order_items

订单和媒体的多对多关系：一个订单包含哪些文件。

```sql
CREATE TABLE order_items (
    order_id    BIGINT NOT NULL REFERENCES orders(id),
    media_id    BIGINT NOT NULL REFERENCES media(id),
    price_cents INTEGER NOT NULL CHECK (price_cents >= 0),  -- 下单时的价格快照
    PRIMARY KEY (order_id, media_id)
);
```

## reviews

双向评价，每条评价必须对应一个订单。

```sql
CREATE TABLE reviews (
    order_id    BIGINT NOT NULL REFERENCES orders(id),
    reviewer_id BIGINT NOT NULL REFERENCES users(id),
    reviewed_id BIGINT NOT NULL REFERENCES users(id),
    rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    content     TEXT,
    posted_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (order_id, reviewer_id),
    CHECK (reviewer_id <> reviewed_id)
);
```

## 待定问题

1. **定价方式。** 目前假设按单张定价（`media.price_cents`）。如果改成按套餐或按场次定价，需要新增表。
2. **拍摄场次（shoot sessions）。** 目前照片直接记录雪场和拍摄时间，不设场次这一层。如果以后需要“相册”式的浏览，或者按场次打包定价，再加 `shoot_sessions` 表。
3. **预约（marketplace 模式）。** 预约和订单是两件事：预约是“约好某天拍摄”，订单是“购买照片”。如果采用 marketplace 模式，另建 `bookings` 表，取消状态放在那里。
4. **摄影师给顾客评价是否有必要。** 在 B2B2C 模式下作用不大。表结构已经支持双向评价，产品上是否开放待定。
5. **B2B2C 模式下的隐私。** 陌生人能否浏览别人的带水印预览图？这会影响权限设计。
6. **身份认证库。** 选定后，`users` 表的结构以它为准，并可能新增 session 等表。
