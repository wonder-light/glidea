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
  name: "",
  repo: "",
  // 禁用相对路径
  relativePath: false,
  basePath: "/",
  homepage: "READEME.md",
  loadNavbar: true,
  // 小屏设备下合并导航栏到侧边栏
  mergeNavbar: true,
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
  plugins: [hideEmptySidebar],
  // vue 全局选项
  vueGlobalOptions: {
    data() {
      return {
        count: 0,
      };
    },
  },
};
