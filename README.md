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
