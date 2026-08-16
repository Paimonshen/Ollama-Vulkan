# Ollama-Vulkan

**Ollama（Windows 版）· Vulkan GPU 后端构建** — 让 Ollama 通过 Vulkan 调用 Intel / AMD / NVIDIA 显卡加速本地大模型推理。

本项目基于上游 [ollama/ollama](https://github.com/ollama/ollama)（v0.32.6）构建，额外启用 Vulkan 后端，并对构建流程做了整理，开箱即用。

## 特性

- ✅ Ollama v0.32.6 + llama.cpp Vulkan 后端（`ggml-vulkan.dll`）
- ✅ 支持 Intel Arc / NVIDIA / AMD 等 Vulkan 显卡
- ✅ 成品包自包含：解压即用，无需安装 Vulkan SDK
- ✅ `build.bat` 一键编译 / 打包，源码与上游保持一致，便于同步更新

## 硬件与系统要求

- Windows 10/11 x64
- 支持 Vulkan 1.2+ 的显卡（Intel Arc / Iris Xe、NVIDIA GTX/RTX、AMD RX 等）
- 最新显卡驱动

## 下载与使用

从本项目 **Releases** 页面下载 `Ollama-Vulkan.zip`（约 38 MB），解压后双击 `start-ollama.bat`：

```bat
start-ollama.bat
```

服务启动后默认监听 `127.0.0.1:11434`，验证 GPU 是否被识别：

```bat
curl http://127.0.0.1:11434/api/tags
ollama run qwen2.5:3b
```

启动日志中应出现类似：

```
inference compute ... library=Vulkan name=Vulkan0 description="Intel(R) Arc(TM) B580 Graphics"
  type=discrete total="11.8 GiB" available="11.1 GiB"
```

## 目录结构

```
Ollama-Vulkan/
├─ Source/                 # 源码（含 build.bat 构建脚本）
├─ Ollama-Vulkan/          # 成品文件夹（解压即用）
├─ Ollama-Vulkan.zip       # 成品压缩包
└─ README.md
```

## 从源码构建

### 前置条件

- Visual Studio 2022 Build Tools（VC v143）
- [Vulkan SDK](https://vulkan.lunarg.com/sdk/home)（默认路径 `C:\VulkanSDK\1.4.309.0`，或设置环境变量 `VULKAN_SDK`）
- CMake、Ninja、Git、Go（或在 `work\tools` 中放置，脚本会自动识别）

### 构建

```bat
cd Source
build.bat package
```

等价于 `configure` → `build` → 组装成品到 `..\Ollama-Vulkan\`，之后可按提示打包为 `Ollama-Vulkan.zip`。

## 同步上游更新

`Source` 是一个干净的 Ollama 上游 checkout（`main` 分支 = 上游 c82ebbd）。同步最新上游：

```bat
git fetch origin
git rebase origin/master
```

本项目未改动 Ollama 的任何业务代码，只调整了构建参数，因此理论上可以直接跟随上游。

## 致谢

- [ollama/ollama](https://github.com/ollama/ollama) — 本项目基于上游构建
- [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) — Vulkan 推理后端

## License

Ollama 上游使用 MIT License，本项目同样遵循。
