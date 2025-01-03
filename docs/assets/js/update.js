// 在 node.js 执行
const fs = require("fs");
const path = require("path");

const configPath = path.normalize(path.join(__dirname, "../config/themes.json"));
// Github 令牌, 减缓 Github 的限速限制
const auth = "";

// 配置
let config = JSON.parse(fs.readFileSync(configPath, { encoding: "utf-8" }));
if (!config) config = {};

function sleep(delaytime = 1000) {
  return new Promise((resolve) => setTimeout(resolve, delaytime));
}

/**
 * 更新主题的函数
 * @param {string} query 查询
 * @param {string} auth 授权
 * @param {(result: any) => ({totalCount: number, pageInfo: object, nodes: []})} format 返回格式化的数据
 * @param {(data: any) => Promise<{name: string, owner: string, intr: string, secr: string, prev: string, repo: string}|null>} handle 处理数据
 * @param {string|null|undefined} startCursor
 * @returns {Promise<any[]>}
 */
async function updateTheme(query, auth, format, handle, startCursor) {
  let myHeaders = new Headers();
  myHeaders.append("Authorization", `Bearer ${auth}`);
  myHeaders.append("Content-Type", "application/json");

  let graphql = JSON.stringify({
    query: query,
    variables: {
      startCursor: !startCursor ? "" : startCursor,
    },
  });

  let requestOptions = {
    method: "POST",
    headers: myHeaders,
    body: graphql,
  };

  let items = [];

  // 获取数据
  let data = await fetch("https://api.github.com/graphql", requestOptions)
    .then((response) => response.json())
    .then((result) => format(result))
    .catch((error) => ({}));

  // 没有则返回
  if (!data.nodes?.length) {
    return items;
  }

  // 添加
  let nodes = [];
  for (const item of data.nodes) {
    try {
      let value = await handle(item);
      if (value) {
        nodes.push(value);
      }
    } catch (e) {}
  }

  items.push(...nodes);

  // 下一页
  if (data.pageInfo.hasNextPage) {
    await sleep();
    let values = await updateTheme(query, auth, format, handle, data.pageInfo.hasNextPage);
    items.push(...values);
  }

  return items;
}

// 从 Github 中搜索对应 topic 的仓库
async function updateRepoTheme() {
  let query = `
    query($startCursor: String) {
      topic(name: "glidea-theme") {
        repositories(first: 30, visibility: PUBLIC, after: $startCursor) {
          totalCount
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
          nodes {
            name
            owner {
              login
            }
            refs(first: 1, refPrefix: "refs/heads/") {
              nodes {
                name
              }
            }
            description
            url
            homepageUrl
            openGraphImageUrl
            stargazerCount
            createdAt
            pushedAt
          }
        }
      }
    }
  `;
  let format = (result) => ({
    totalCount: result.data.topic.repositories.totalCount,
    pageInfo: result.data.topic.repositories.pageInfo,
    nodes: result.data.topic.repositories.nodes,
  });
  let handle = async (node) => {
    // 获取 README.md
    let url = `https://raw.githubusercontent.com/${node.owner.login}/${node.name}/refs/heads/${node.refs.nodes[0].name}/README.md`;
    let text = await fetch(url).then((result) => result.text());
    // 设置数据
    let secr = text.match(/\[screenshots\]\:(.*)/)?.[1];
    if (!secr) secr = "";
    let prev = text.match(/\[preview\]\:(.*)/)?.[1];
    if (!prev) prev = !node.homepageUrl ? node.url : node.homepageUrl;
    let intr = text.match(/\[introduce\]\:(.*)/)?.[1];
    if (!intr) intr = "";

    return {
      name: node.name.replace("glidea-theme-", ""),
      owner: node.owner.login,
      intr: intr,
      secr: secr,
      prev: prev,
      repo: node.url,
      star: node.stargazerCount,
    };
  };
  return await updateTheme(query, auth, format, handle, null);
}

// 从讨论区中搜索
async function updateDiscussionTheme() {
  let query = `
    query($startCursor: String) {
      repository(owner: "wonder-light", name: "glidea") {
        discussion(number: 3) {
          comments(first: 40, after: $startCursor) {
            totalCount
            pageInfo {
              startCursor
              endCursor
              hasNextPage
              hasPreviousPage
            }
            nodes {
              author {
                login
              }
              body
              upvoteCount
              createdAt
              updatedAt
            }
          }
        }
      }
    }
  `;
  let format = (result) => ({
    totalCount: result.data.repository.discussion.comments.totalCount,
    pageInfo: result.data.repository.discussion.comments.pageInfo,
    nodes: result.data.repository.discussion.comments.nodes,
  });
  let handle = async (node) => {
    let text = node.body;
    // 设置数据
    let name = text.match(/\[theme\]\:(.*)/)?.[1];
    if (!name) name = "";
    let intr = text.match(/\[introduce\]\:(.*)/)?.[1];
    if (!intr) intr = "";
    let prev = text.match(/\[preview\]\:(.*)/)?.[1];
    if (!prev) prev = !node.homepageUrl ? node.url : node.homepageUrl;
    let repo = text.match(/\[repository\]\:(.*)/)?.[1];
    if (!repo) repo = "";
    let secr = text.match(/\[screenshots\]\:(.*)/)?.[1];
    if (!secr) secr = "";

    if (!name && !repo) return null;

    return {
      name: name,
      owner: node.author.login,
      intr: intr,
      secr: secr,
      prev: prev,
      repo: repo,
      star: node.upvoteCount,
    };
  };
  return await updateTheme(query, auth, format, handle, null);
}

async function execRepo() {
  config.githubItems = await updateRepoTheme();
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
}

async function execDiscussion() {
  config.defaultItems = await updateDiscussionTheme();
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
}

// execRepo();

exports.execRepo = execRepo;
exports.execDiscussion = execDiscussion;
