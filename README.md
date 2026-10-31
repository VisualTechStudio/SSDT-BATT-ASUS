<div align="center">
             <h1>SSDT-BATT-ASUS</h1>
             Fixing battery and charging status for ASUS AMD (TUF/TX series) laptops in Hackintosh
             <br>
             <br>
             <img src="https://img.shields.io/github/release/VisualTechStudio/SSDT-BATT-ASUS" />
             <img src="https://img.shields.io/github/stars/VisualTechStudio/SSDT-BATT-ASUS" />
             <br>
             <br>
             <a href="README_en_US.md">English Readme</a>
</div>



## 概述

本项目提供了一套针对华硕 AMD 平台笔记本（天选 TUF / TX 系列）的底层 ACPI 电池状态修复热补丁。

在部分华硕 AMD 机型中，由于原厂 DSDT 电池通信逻辑与 macOS ACPI/SMC 架构存在兼容性问题，常年表现为电量不刷新、充放电状态识别错乱或无电池图标。本 SSDT 不直接修改 DSDT，而是通过引导器重命名补丁与物理内存直接映射技术，接管 `BAT1._BST` 与 `ACAD._PSR`，实现高可靠性的电池遥测数据同步。

| ACPI 表属性 | 规格参数 |
| --- | --- |
| **表签名 (Signature)** | `SSDT` |
| **OEM ID** | `ASUS` |
| **OEM Table ID** | `BATT` |
| **编译器** | `INTL 20200925` (ACPICA) |

---

## 核心技术原理

### 1. 物理内存直接映射 (Bypassing EmbeddedControl)

传统的 `EmbeddedControl` 操作区方案在多线程或休眠唤醒时常伴随寻址延迟与兼容性问题。本补丁将华硕固件映射的 EC RAM 物理内存窗口（基址 `0xFEDD8300`，大小 256 字节）直接声明为 `SystemMemory` 操作区：

```asl
OperationRegion (ZBAT, SystemMemory, 0xFEDD8300, 0x0100)

```

通过精确的字段偏移（如 `0x46` 处的电流、`0x48` 处的剩余容量、`0xE7` 处的电池状态码等），绕过易出问题的标准 EC 寻址路径，直接从内存镜像读取遥测数据。

### 2. 方法重命名与钩子劫持

* **`BAT1._BST`**：原方法被 bootloader 重命名为 `XBST`。本表通过 `External` 引用原方法作为兜底，并注入全新的 `_BST` 逻辑。在调用原方法获取基础结构后，利用 `ZSTS()` 状态机动态修正充放电位、速率和电压。
* **`ACAD._PSR`**：在 `_SB.ACAD` 作用域内重新定义 `_PSR`，结合 `ECOK` 标志位判断电源状态，避免在 EC 初始化早期阶段误报。


## 运行时依赖

* **macOS 环境**：需配合消费 `_BST` 数据的虚拟 SMC 插件使用（推荐 **`SMCBatteryManager.kext`**）。macOS 原生电池路径最终由 SMC 呈现。
* **DSDT 目标对象要求**：系统 DSDT 必须包含 `_SB.ACAD`、`_SB.BAT1` 以及标准华硕风格的南桥 LPC 命名空间 `_SB.PCI0.SBRG.EC0`。


---

## 许可协议

本项目遵循 **CC BY-NC 4.0** (知识共享 署名-非商业性使用) 协议开源。详情见 LICENSE 文件。

# 如何使用

- 添加SSDT至ACPI-Add
1. 下载[OCAT](https://github.com/ic005k/OCAuxiliaryTools)
2. 使用OCAT打开EFI\OC\config.plist
3. 前往ACPI-Add，添加SSDT-BATT-ASUS并启用


- 添加 ACPI Patch

| Comment | Enabled | Find | Replace |
| :--- | :---: | :--- | :--- |
| `Battery: rename _BST to XBST (DSDT only) - SSDT-BATT provides new _BST` | `True` | `5F425354` | `58425354` |
| `Battery: rename _PSR to XPSR (DSDT only) - SSDT-BATT provides clean AC detect` | `True` | `5F505352` | `58505352` |
