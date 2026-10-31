/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (32-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of C:/Users/t3228/Desktop/SSDT-BATT-ASUS/SSDT-BATT-ASUS.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000311 (785)
 *     Revision         0x02
 *     Checksum         0xE0
 *     OEM ID           "ASUS"
 *     OEM Table ID     "BATT"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200925 (538970405)
 */
DefinitionBlock ("", "SSDT", 2, "ASUS", "BATT", 0x00001000)
{
    External (_SB_.ACAD, DeviceObj)
    External (_SB_.BAT1, DeviceObj)
    External (_SB_.BAT1.XBST, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.SBRG.EC0_, DeviceObj)
    External (_SB_.PCI0.SBRG.EC0_.ECOK, IntObj)

    Scope (_SB.PCI0.SBRG.EC0)
    {
        OperationRegion (ZBAT, SystemMemory, 0xFEDD8300, 0x0100)
        Field (ZBAT, ByteAcc, NoLock, Preserve)
        {
            Offset (0x44), 
            ZACN,   1, 
            Offset (0x45), 
            Offset (0x46), 
            ZMCL,   8, 
            ZMCH,   8, 
            ZRCL,   8, 
            ZRCH,   8, 
            ZMVL,   8, 
            ZMVH,   8, 
            Offset (0x5E), 
            ZNAC,   1, 
            Offset (0x5F), 
            Offset (0x6C), 
            ZMFL,   8, 
            ZMFH,   8, 
            Offset (0xCA), 
                ,   1, 
            ZACO,   1, 
            Offset (0xCB), 
            Offset (0xE7), 
            ZBHC,   8
        }

        Method (ZB12, 2, NotSerialized)
        {
            Return (((Arg1 << 0x08) | Arg0))
        }

        Method (ZCUR, 0, NotSerialized)
        {
            Local0 = ZB12 (ZMCL, ZMCH)
            If ((Local0 >= 0x8000))
            {
                Local0 -= 0x00010000
            }

            Return (Local0)
        }

        Method (ZRAT, 0, NotSerialized)
        {
            Local0 = ZCUR ()
            If ((Local0 < Zero))
            {
                Local0 = (~Local0 + One)
            }

            Return (Local0)
        }

        Method (ZREM, 0, NotSerialized)
        {
            Return (ZB12 (ZRCL, ZRCH))
        }

        Method (ZACI, 0, NotSerialized)
        {
            If ((ZACN || ZACO))
            {
                Return (One)
            }

            Return (Zero)
        }

        Method (ZSTS, 0, NotSerialized)
        {
            Local0 = Zero
            Local1 = ZCUR ()
            Local2 = ZREM ()
            Local3 = ZB12 (ZMFL, ZMFH)
            Local4 = ZACI ()
            If ((Local4 == Zero))
            {
                Local0 = One
            }
            ElseIf (((Local1 < Zero) || (ZBHC == 0x50)))
            {
                Local0 = 0x02
            }
            Else
            {
                Local5 = ((Local3 * 0x63) / 0x64)
                If (((Local3 != Zero) && (Local2 < Local5)))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = Zero
                }
            }

            If ((Local3 != Zero))
            {
                If (((Local2 * 0x14) <= Local3))
                {
                    Local0 |= 0x04
                }
            }

            Return (Local0)
        }
    }

    Scope (_SB.ACAD)
    {
        Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
        {
            If (\_SB.PCI0.SBRG.EC0.ECOK)
            {
                Return (\_SB.PCI0.SBRG.EC0.ZACI ())
            }

            Return (One)
        }
    }

    Scope (_SB.BAT1)
    {
        Method (_BST, 0, NotSerialized)  // _BST: Battery Status
        {
            Local0 = Package (0x04)
                {
                    One, 
                    Zero, 
                    Zero, 
                    0x0BB8
                }
            If (\_SB.PCI0.SBRG.EC0.ECOK)
            {
                Local1 = XBST ()
                Local3 = DerefOf (Local1 [One])
                Local4 = DerefOf (Local1 [0x02])
                Local5 = DerefOf (Local1 [0x03])
                Local0 [Zero] = \_SB.PCI0.SBRG.EC0.ZSTS ()
                If ((Local3 == Zero))
                {
                    Local3 = \_SB.PCI0.SBRG.EC0.ZRAT ()
                }

                If ((Local4 == Zero))
                {
                    Local4 = \_SB.PCI0.SBRG.EC0.ZREM ()
                }

                If ((Local5 == Zero))
                {
                    Local5 = 0x0BB8
                }

                Local0 [One] = Local3
                Local0 [0x02] = Local4
                Local0 [0x03] = Local5
            }

            Return (Local0)
        }
    }
}

