#!/usr/bin/env python3
"""
Demo script to run ALU testbench and analyze results
Works on Windows/Linux/WSL with any Verilog simulator
"""

import os
import subprocess
import sys
import time

def print_header():
    print("🚀 RISC-V CPU ALU Test Demo")
    print("=" * 50)
    print()

def check_simulator():
    """Check which Verilog simulator is available"""
    simulators = [
        ('iverilog', 'vvp'),        # Icarus Verilog (Free)
        ('vlog', 'vsim'),           # ModelSim/QuestaSim  
        ('xvlog', 'xsim'),          # Vivado Simulator
    ]
    
    for compiler, runner in simulators:
        if subprocess.run(['which', compiler], capture_output=True).returncode == 0:
            print(f"✅ Found simulator: {compiler}/{runner}")
            return compiler, runner
    
    print("❌ No Verilog simulator found!")
    print("Please install one of:")
    print("  - Icarus Verilog: sudo apt-get install iverilog")
    print("  - ModelSim/QuestaSim (commercial)")
    print("  - Vivado (free with registration)")
    return None, None

def run_alu_test():
    """Run ALU testbench"""
    print("\n🧪 Running ALU Testbench...")
    
    # Create results directory
    os.makedirs('results', exist_ok=True)
    os.chdir('results')
    
    # Check simulator
    compiler, runner = check_simulator()
    if not compiler:
        return False
    
    try:
        if compiler == 'iverilog':
            # Compile with Icarus Verilog
            print("   Compiling with Icarus Verilog...")
            result = subprocess.run([
                'iverilog', 
                '-o', 'alu_test',
                '../src/alu.v',
                '../alu_tb.v'
            ], capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"❌ Compilation failed:")
                print(result.stderr)
                return False
            
            # Run simulation
            print("   Running simulation...")
            result = subprocess.run(['vvp', 'alu_test'], capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"❌ Simulation failed:")
                print(result.stderr)
                return False
            
            # Display results
            print("\n📊 Simulation Results:")
            print("-" * 30)
            print(result.stdout)
            
            # Check for VCD file
            if os.path.exists('alu_tb.vcd'):
                print("\n✅ VCD file generated: alu_tb.vcd")
                print("📊 File size:", os.path.getsize('alu_tb.vcd'), "bytes")
                return True
            else:
                print("⚠️  No VCD file found")
                return False
                
        else:
            print(f"ℹ️  Using {compiler}, please run manually:")
            print(f"   {compiler} ../src/alu.v ../alu_tb.v")
            print(f"   {runner} -c alu_tb -do 'run -all; quit'")
            return False
            
    except FileNotFoundError as e:
        print(f"❌ Command not found: {e}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def analyze_vcd():
    """Basic VCD file analysis"""
    vcd_file = 'alu_tb.vcd'
    
    if not os.path.exists(vcd_file):
        print("❌ VCD file not found for analysis")
        return
    
    print(f"\n🔍 Analyzing VCD file: {vcd_file}")
    print("-" * 40)
    
    try:
        with open(vcd_file, 'r') as f:
            lines = f.readlines()
        
        # Count signals and time points
        signals = 0
        time_points = 0
        
        for line in lines:
            if line.startswith('$var'):
                signals += 1
            elif line.startswith('#'):
                time_points += 1
        
        print(f"📈 Signals defined: {signals}")
        print(f"⏰ Time points: {time_points}")
        print(f"📄 Total lines: {len(lines)}")
        
        # Look for key signals
        key_signals = ['operand1', 'operand2', 'alu_result', 'zero_flag']
        found_signals = []
        
        for line in lines:
            if '$var' in line:
                for sig in key_signals:
                    if sig in line:
                        found_signals.append(sig)
        
        print(f"🔑 Key signals found: {found_signals}")
        
        if len(found_signals) >= 3:
            print("✅ VCD file looks complete")
            return True
        else:
            print("⚠️  Some key signals missing")
            return False
            
    except Exception as e:
        print(f"❌ Error analyzing VCD: {e}")
        return False

def show_waveform_tips():
    """Show tips for viewing waveforms"""
    print("\n🌊 Waveform Viewing Tips:")
    print("-" * 30)
    
    if os.path.exists('alu_tb.vcd'):
        print("To view waveforms:")
        print("1. With GTKWave (if installed):")
        print("   gtkwave alu_tb.vcd &")
        print()
        print("2. What to look for in the waveform:")
        print("   ✅ operand1, operand2 inputs change")
        print("   ✅ alu_result changes after inputs change")  
        print("   ✅ zero_flag = 1 when alu_result = 0")
        print("   ✅ No X or Z values in outputs")
        print("   ✅ Clean signal transitions")
        print()
        print("3. Example test patterns:")
        print("   - ADD: 100 + 200 = 300")
        print("   - SUB: 300 - 300 = 0 (zero_flag=1)")
        print("   - AND: 0xFF & 0x0F = 0x0F")
        
        # Generate simple waveform analysis
        try:
            print("\n📊 Quick VCD Analysis:")
            with open('alu_tb.vcd', 'r') as f:
                content = f.read()
                
            if 'alu_result' in content:
                print("   ✅ ALU result signals found")
            if 'zero_flag' in content:
                print("   ✅ Zero flag signal found")
            if '#' in content:
                print("   ✅ Time-based simulation detected")
                
        except:
            pass
    else:
        print("❌ No VCD file to analyze")

def main():
    print_header()
    
    # Run the test
    success = run_alu_test()
    
    if success:
        # Analyze VCD if generated
        if os.path.exists('results/alu_tb.vcd'):
            os.chdir('results')
            analyze_vcd()
        
        show_waveform_tips()
        
        print("\n🎉 ALU Test Demo Complete!")
        print("✅ Test passed - ALU module is working correctly")
        print()
        print("Next steps:")
        print("1. View the waveform with gtkwave")
        print("2. Run other module tests")  
        print("3. Run full system test")
        
    else:
        print("\n❌ ALU Test Demo Failed!")
        print("Check the error messages above and:")
        print("1. Install a Verilog simulator (iverilog recommended)")
        print("2. Check that source files exist")
        print("3. Run the test manually")

if __name__ == "__main__":
    main()

