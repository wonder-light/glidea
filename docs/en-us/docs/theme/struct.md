
# File structure :id=struct

> Themes have some strongly agreed directory structures and optional static resource directories

<br/>

```
fly --------------------- Subject folder name (lowercase, delimited by a hyphen is recommended)
├── assets -------------- Resource folder (optional, cannot be renamed)
│   ├── media ----------- Theme Static resource directory (optional, cannot be renamed)
│   │   └── fonts ------- Font ICONS Folder (Example)
│   │   └── images ------ Image file for theme (Example)
│   ├── styles ---------- Style folder (optional, not renaming)
│   │  └── main.css ----- Master style file (optional, not renaming)
├── static -------------- Static resource (optional, cannot be renamed)
│   │  └── robots.txt --- (Example)
└── templates ----------- Page Templates folder (required, not renamed)
│   ├── _blocks --------- Page templates folder (optional, you can customize the name)
│   │   ├── footer.j2
│   │   ├── head.j2
│   │   ├── header.j2
│   ├── index.j2 -------- Home page, list page (required, not renamed)
│   ├── post.j2 --------- Post page, list page (required, not renamed)
│   ├── archives.j2 ----- Archives page, list page (required, not renamed)
│   ├── tags.j2 --------- Tags page, list page (required, not renamed)
│   ├── tag.j2 ---------- Tag page, list page (required, not renamed)
│   └── friends.j2 ------ Custom template (optional, any name)
├── config.json --------- Theme profile (Optional, recommended)
└── style-override.j2 - Theme Style Custom file (optional)
```

<br/>

As you can see, there are only five required files，`index.j2`, `post.j2`, `archives.j2`, `tags.j2`, `tag.j2`
（The organization must be based on the corresponding directory）
