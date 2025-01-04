// vue3 主题卡片组件
const themeCard = {
  template: `
    <div class="theme-card">
      <div class="theme-content">
        <a class="theme-img" :style='{ backgroundImage: "url(" + secr +")" }'></a>
        <div class="theme-button">
          <div class="theme-text">{{name}}</div>
          <div>
            <a :href="prev" class="theme-icon" target="_blank">
              <img src="/assets/images/eye.svg" alt="预览"/>
            </a>
            <a :href="repo" class="theme-icon" target="_blank">
              <img src="/assets/images/download.svg" alt="仓库"/>
            </a>
          </div>
        </div>
      </div>
    </div>
  `,
  props: {
    name: String, // 主题名
    secr: String, // 截图
    prev: String, // 预览地址
    repo: String, // 仓库地址
  },
  data() {
    return {};
  },
};

// 主题列表
const themeList = {
  template: `
    <div>
      <div align="center">
        <a href="/zh-cn/docs/theme/shared" class="a-button-cover" style="display: inline-flex; cursor: pointer">
          <img src="/assets/images/clothes-line.svg" alt="clothes-line.svg" style="width: 1rem; margin-right: 0.5rem;"/>
          {{ shared }}
          <img src="/assets/images/right-arrow.svg" alt="right-arrow.svg" style="width: 1rem; margin-left: 0.4rem;"/>
        </a>
      </div>
      <div class="left-segm" style="padding-right: 1rem">
        <el-segmented v-model="currentOption" :options="options"></el-segmented>
      </div>
      <div v-if="getItems.length > 0" :class="{ 'theme-list': true, 'jc-center': getItems.length <= 1 }">
        <theme-card v-for="item in getItems" :name="item.name" :secr="item.secr" :prev="item.prev" :repo="item.repo"> </theme-card>
      </div>
      <div v-else>
        <el-empty :image-size="200"></el-empty>
      </div>
      <div v-if="hasMoreData" align="center">
        <div class="a-button" style="display: inline-block; cursor: pointer">
          {{ loadTip }}
        </div>
      </div>
    </div>
  `,
  inject: ["defaultItems", "githubItems"],
  props: {
    label: String,
    shared: String,
  },
  data() {
    return {
      currentOption: this.label,
      options: [this.label, "Github"],
      hasMoreData: false,
    };
  },
  computed: {
    isGithub() {
      return this.currentOption == "Github";
    },
    getItems() {
      return this.isGithub ? this.githubItems : this.defaultItems;
    },
  },
  created() {
    fetch("/assets/config/themes.json")
      .then((response) => response.json())
      .then((data) => {
        this.githubItems = data.githubItems;
        this.defaultItems = data.defaultItems;
      });
  },
};

// 隐藏空侧边栏的插件函数
function hideEmptySidebar(hook, vm) {
  const setHide = () => {
    let ma = document.querySelector("body>main");
    let num = document.querySelectorAll(".sidebar-nav ul li").length;
    if (num > 0) {
      // 显示
      ma.classList.remove("b-main-hide");
    } else {
      // 隐藏
      if (!ma.classList.contains("b-main-hide")) {
        ma.classList.add("b-main-hide");
      }
    }
  };
  hook.doneEach(() => setHide());
  hook.ready(() => setHide());
}

// docsify 配置
window.$docsify = {
  name: "glidea",
  repo: "",
  logo: "/assets/images/logo.png",
  // 禁用相对路径
  relativePath: false,
  basePath: "/",
  homepage: "README.md",
  notFoundPage: "not-found.md",
  // 切换页面后是否自动跳转到页面顶部
  auto2top: true,
  loadNavbar: true,
  // 小屏设备下合并导航栏到侧边栏
  mergeNavbar: false,
  loadSidebar: true,
  hideSidebar: false,
  subMaxLevel: 3,
  // set sidebar display level
  sidebarDisplayLevel: 1,
  autoHeader: true,
  // 执行文档里的 script 标签里的脚本
  executeScript: true,
  coverpage: ["/", "/en-us/"],
  // 路由模式
  routerMode: "history",
  formatUpdated: "{YYYY}/{MM}/{DD} {HH}:{mm}:{ss}",
  alias: {
    "/zh-cn/.*/_navbar.md": "/_navbar.md",
    "/en-us/.*/_navbar.md": "/en-us/_navbar.md",
    "/([a-z]*-[a-z]*)/docs/.*/_sidebar.md": "/$1/docs/_sidebar.md",
  },
  plugins: [hideEmptySidebar],
  // vue 组件
  vueComponents: {
    "theme-card": themeCard,
    "theme-list": themeList,
    ElSegmented: ElementPlus.ElSegmented,
    ElEmpty: ElementPlus.ElEmpty,
  },
  // vue 全局选项
  vueGlobalOptions: {
    data() {
      return {
        defaultItems: [],
        githubItems: [],
      };
    },
    provide() {
      return {
        defaultItems: Vue.computed({
          get: () => this.defaultItems,
          set: (value) => (this.defaultItems = value),
        }),
        githubItems: Vue.computed({
          get: () => this.githubItems,
          set: (value) => (this.githubItems = value),
        }),
      };
    },
  },
};
