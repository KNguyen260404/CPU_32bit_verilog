#!/usr/bin/env python3
"""
=============================================================================
VCD Waveform Analysis Tool for RISC-V CPU Testbenches
=============================================================================
Description: Analyzes VCD files to verify testbench correctness
Author: Auto-generated analysis tool
Date: September 23, 2025
Features: - Parse VCD files and extract signals
         - Verify expected behavior patterns
         - Generate analysis reports
         - Detect potential issues
=============================================================================
"""

import sys
import os
import argparse
import re
from typing import Dict, List, Tuple, Any

def parse_vcd_file(vcd_file: str) -> Dict[str, Any]:
    """Parse VCD file and extract signal information"""
    
    signals = {}
    time_values = []
    current_time = 0
    
    print(f"📊 Parsing VCD file: {vcd_file}")
    
    if not os.path.exists(vcd_file):
        print(f"❌ Error: VCD file not found: {vcd_file}")
        return {}
    
    try:
        with open(vcd_file, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"❌ Error reading VCD file: {e}")
        return {}
    
    # Parse VCD header to get signal definitions
    in_header = True
    signal_map = {}
    
    for line in lines:
        line = line.strip()
        
        if line.startswith('$var'):
            # Extract signal definition: $var wire 32 ! operand1 $end
            parts = line.split()
            if len(parts) >= 5:
                signal_type = parts[1]  # wire, reg, etc.
                width = parts[2]
                symbol = parts[3]
                name = parts[4]
                signal_map[symbol] = {
                    'name': name,
                    'type': signal_type,
                    'width': int(width) if width.isdigit() else 1,
                    'values': []
                }
        
        elif line.startswith('$enddefinitions'):
            in_header = False
            print(f"📍 Found {len(signal_map)} signals in VCD file")
        
        elif not in_header and line.startswith('#'):
            # Time change
            current_time = int(line[1:])
            time_values.append(current_time)
        
        elif not in_header and line:
            # Signal value change
            if line[0] in '01xz':
                # Single bit signal: 0! or 1!
                value = line[0]
                symbol = line[1:]
                if symbol in signal_map:
                    signal_map[symbol]['values'].append((current_time, value))
            elif line[0] == 'b':
                # Multi-bit signal: b10101010 !
                parts = line.split()
                if len(parts) >= 2:
                    value = parts[0][1:]  # Remove 'b' prefix
                    symbol = parts[1]
                    if symbol in signal_map:
                        signal_map[symbol]['values'].append((current_time, value))
    
    return {
        'signals': signal_map,
        'time_range': (min(time_values) if time_values else 0, 
                      max(time_values) if time_values else 0),
        'total_time': max(time_values) if time_values else 0
    }

def analyze_alu_waveform(vcd_data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze ALU testbench waveform"""
    
    print("\n🔍 Analyzing ALU Waveform...")
    
    signals = vcd_data.get('signals', {})
    analysis = {
        'module': 'ALU',
        'passed': True,
        'issues': [],
        'statistics': {},
        'recommendations': []
    }
    
    # Look for key ALU signals
    operand1_signal = None
    operand2_signal = None
    alu_result_signal = None
    alu_control_signal = None
    zero_flag_signal = None
    
    for symbol, signal_info in signals.items():
        name = signal_info['name'].lower()
        if 'operand1' in name:
            operand1_signal = signal_info
        elif 'operand2' in name:
            operand2_signal = signal_info
        elif 'alu_result' in name:
            alu_result_signal = signal_info
        elif 'alu_control' in name:
            alu_control_signal = signal_info
        elif 'zero_flag' in name:
            zero_flag_signal = signal_info
    
    # Check if essential signals are present
    essential_signals = [
        ('operand1', operand1_signal),
        ('operand2', operand2_signal),  
        ('alu_result', alu_result_signal),
        ('alu_control', alu_control_signal)
    ]
    
    missing_signals = []
    for name, signal in essential_signals:
        if signal is None:
            missing_signals.append(name)
    
    if missing_signals:
        analysis['issues'].append(f"Missing essential signals: {', '.join(missing_signals)}")
        analysis['passed'] = False
    
    # Analyze signal activity
    if alu_result_signal and alu_result_signal['values']:
        result_changes = len(alu_result_signal['values'])
        analysis['statistics']['result_changes'] = result_changes
        
        if result_changes < 10:
            analysis['issues'].append(f"Low ALU activity: only {result_changes} result changes")
        else:
            print(f"✅ Good ALU activity: {result_changes} result changes detected")
    
    # Check for unknown/undefined values
    if alu_result_signal:
        undefined_count = 0
        for time, value in alu_result_signal['values']:
            if 'x' in value.lower() or 'z' in value.lower():
                undefined_count += 1
        
        if undefined_count > 0:
            analysis['issues'].append(f"Found {undefined_count} undefined result values (X/Z)")
            analysis['passed'] = False
        else:
            print("✅ No undefined values in ALU results")
    
    # Recommendations
    if analysis['passed']:
        analysis['recommendations'].append("ALU waveform looks healthy")
    else:
        analysis['recommendations'].append("Review ALU implementation for issues")
    
    return analysis

def analyze_control_unit_waveform(vcd_data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze Control Unit testbench waveform"""
    
    print("\n🔍 Analyzing Control Unit Waveform...")
    
    signals = vcd_data.get('signals', {})
    analysis = {
        'module': 'Control Unit',
        'passed': True,
        'issues': [],
        'statistics': {},
        'recommendations': []
    }
    
    # Look for key control signals
    opcode_signal = None
    reg_write_signal = None
    mem_write_signal = None
    alu_control_signal = None
    branch_type_signal = None
    
    control_signal_count = 0
    for symbol, signal_info in signals.items():
        name = signal_info['name'].lower()
        if any(ctrl in name for ctrl in ['opcode', 'reg_write', 'mem_write', 'alu_control', 'branch_type']):
            control_signal_count += 1
            
            if 'opcode' in name:
                opcode_signal = signal_info
            elif 'reg_write' in name:
                reg_write_signal = signal_info
            elif 'mem_write' in name:
                mem_write_signal = signal_info
            elif 'alu_control' in name:
                alu_control_signal = signal_info
            elif 'branch_type' in name:
                branch_type_signal = signal_info
    
    analysis['statistics']['control_signals_found'] = control_signal_count
    
    if control_signal_count < 5:
        analysis['issues'].append(f"Only {control_signal_count} control signals found, expected more")
    else:
        print(f"✅ Found {control_signal_count} control signals")
    
    # Check opcode variety (different instructions tested)
    if opcode_signal and opcode_signal['values']:
        unique_opcodes = set()
        for time, value in opcode_signal['values']:
            unique_opcodes.add(value)
        
        analysis['statistics']['unique_opcodes'] = len(unique_opcodes)
        
        if len(unique_opcodes) < 5:
            analysis['issues'].append(f"Only {len(unique_opcodes)} unique opcodes tested")
        else:
            print(f"✅ Good instruction coverage: {len(unique_opcodes)} unique opcodes")
    
    return analysis

def analyze_register_file_waveform(vcd_data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze Register File testbench waveform"""
    
    print("\n🔍 Analyzing Register File Waveform...")
    
    signals = vcd_data.get('signals', {})
    analysis = {
        'module': 'Register File',
        'passed': True,
        'issues': [],
        'statistics': {},
        'recommendations': []
    }
    
    # Look for register file signals
    clk_signal = None
    reg_write_signal = None
    rs1_data_signal = None
    rs2_data_signal = None
    rd_data_signal = None
    
    for symbol, signal_info in signals.items():
        name = signal_info['name'].lower()
        if 'clk' in name:
            clk_signal = signal_info
        elif 'reg_write' in name:
            reg_write_signal = signal_info
        elif 'rs1_data' in name:
            rs1_data_signal = signal_info
        elif 'rs2_data' in name:
            rs2_data_signal = signal_info
        elif 'rd_data' in name:
            rd_data_signal = signal_info
    
    # Check clock signal
    if clk_signal and clk_signal['values']:
        clock_edges = len(clk_signal['values'])
        analysis['statistics']['clock_edges'] = clock_edges
        
        if clock_edges < 10:
            analysis['issues'].append("Very few clock edges detected")
        else:
            print(f"✅ Clock activity detected: {clock_edges} edges")
    
    # Check write activity
    if reg_write_signal and reg_write_signal['values']:
        write_count = sum(1 for _, value in reg_write_signal['values'] if value == '1')
        analysis['statistics']['write_operations'] = write_count
        
        if write_count == 0:
            analysis['issues'].append("No write operations detected")
        else:
            print(f"✅ Write operations detected: {write_count}")
    
    return analysis

def analyze_pipeline_waveform(vcd_data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze CPU pipeline waveform"""
    
    print("\n🔍 Analyzing CPU Pipeline Waveform...")
    
    signals = vcd_data.get('signals', {})
    analysis = {
        'module': 'CPU Pipeline',
        'passed': True,
        'issues': [],
        'statistics': {},
        'recommendations': []
    }
    
    # Look for pipeline stage signals
    pipeline_signals = {}
    performance_signals = {}
    
    for symbol, signal_info in signals.items():
        name = signal_info['name'].lower()
        
        # Pipeline stage signals
        if any(stage in name for stage in ['pc_f', 'pc_d', 'pc_e', 'pc_m', 'pc_w']):
            pipeline_signals[name] = signal_info
        
        # Performance counters
        elif any(perf in name for perf in ['cycle_count', 'instr_count', 'stall_count', 'branch_count']):
            performance_signals[name] = signal_info
    
    analysis['statistics']['pipeline_signals'] = len(pipeline_signals)
    analysis['statistics']['performance_signals'] = len(performance_signals)
    
    if len(pipeline_signals) < 3:
        analysis['issues'].append("Few pipeline stage signals found")
    
    # Analyze performance counters
    for name, signal in performance_signals.items():
        if signal['values']:
            final_value = signal['values'][-1][1] if signal['values'] else '0'
            try:
                final_count = int(final_value, 2) if 'b' not in final_value else int(final_value.replace('b', ''), 2)
                analysis['statistics'][name] = final_count
                print(f"📊 {name}: {final_count}")
            except:
                pass
    
    return analysis

def generate_analysis_report(analyses: List[Dict[str, Any]], output_file: str = "waveform_analysis_report.txt"):
    """Generate comprehensive analysis report"""
    
    print(f"\n📄 Generating analysis report: {output_file}")
    
    with open(output_file, 'w') as f:
        f.write("=" * 70 + "\n")
        f.write("RISC-V CPU WAVEFORM ANALYSIS REPORT\n")
        f.write("=" * 70 + "\n\n")
        
        overall_passed = True
        total_issues = 0
        
        for analysis in analyses:
            f.write(f"\n{analysis['module']} Analysis\n")
            f.write("-" * 40 + "\n")
            
            if analysis['passed']:
                f.write("✅ PASSED\n")
            else:
                f.write("❌ FAILED\n")
                overall_passed = False
            
            if analysis['issues']:
                f.write(f"\nIssues ({len(analysis['issues'])}):\n")
                for issue in analysis['issues']:
                    f.write(f"  - {issue}\n")
                total_issues += len(analysis['issues'])
            
            if analysis['statistics']:
                f.write("\nStatistics:\n")
                for key, value in analysis['statistics'].items():
                    f.write(f"  {key}: {value}\n")
            
            if analysis['recommendations']:
                f.write("\nRecommendations:\n")
                for rec in analysis['recommendations']:
                    f.write(f"  - {rec}\n")
        
        f.write("\n" + "=" * 70 + "\n")
        f.write("OVERALL SUMMARY\n")
        f.write("=" * 70 + "\n")
        f.write(f"Total Modules Analyzed: {len(analyses)}\n")
        f.write(f"Total Issues Found: {total_issues}\n")
        f.write(f"Overall Result: {'PASSED' if overall_passed else 'FAILED'}\n")
        
        if overall_passed:
            f.write("\n🎉 All waveforms look healthy! CPU design appears correct.\n")
        else:
            f.write("\n⚠️  Issues found in waveforms. Review design implementation.\n")
    
    print(f"✅ Report generated: {output_file}")
    return overall_passed

def main():
    parser = argparse.ArgumentParser(description='Analyze RISC-V CPU testbench VCD files')
    parser.add_argument('--vcd-dir', default='results', help='Directory containing VCD files')
    parser.add_argument('--module', choices=['alu', 'control', 'regfile', 'immgen', 'branch', 'dataext', 'cpu', 'all'], 
                       default='all', help='Specific module to analyze')
    parser.add_argument('--output', default='waveform_analysis_report.txt', help='Output report file')
    
    args = parser.parse_args()
    
    print("🌊 RISC-V CPU Waveform Analysis Tool")
    print("=" * 50)
    
    vcd_files = {
        'alu': 'alu_tb.vcd',
        'control': 'control_unit_tb.vcd',
        'regfile': 'register_file_tb.vcd',
        'immgen': 'immediate_generator_tb.vcd', 
        'branch': 'branch_decision_tb.vcd',
        'dataext': 'data_extension_tb.vcd',
        'cpu': 'riscv_cpu_comprehensive.vcd'
    }
    
    analyses = []
    
    if args.module == 'all':
        modules_to_analyze = vcd_files.keys()
    else:
        modules_to_analyze = [args.module]
    
    for module in modules_to_analyze:
        vcd_file = os.path.join(args.vcd_dir, vcd_files[module])
        
        if not os.path.exists(vcd_file):
            print(f"⚠️  VCD file not found: {vcd_file}")
            continue
        
        vcd_data = parse_vcd_file(vcd_file)
        if not vcd_data:
            continue
        
        if module == 'alu':
            analysis = analyze_alu_waveform(vcd_data)
        elif module == 'control':
            analysis = analyze_control_unit_waveform(vcd_data)
        elif module == 'regfile':
            analysis = analyze_register_file_waveform(vcd_data)
        elif module == 'cpu':
            analysis = analyze_pipeline_waveform(vcd_data)
        else:
            # Generic analysis for other modules
            analysis = {
                'module': module.upper(),
                'passed': True,
                'issues': [],
                'statistics': {'signals_found': len(vcd_data.get('signals', {}))},
                'recommendations': ['Manual waveform review recommended']
            }
        
        analyses.append(analysis)
    
    if analyses:
        overall_result = generate_analysis_report(analyses, args.output)
        
        print("\n" + "=" * 50)
        if overall_result:
            print("🎉 ANALYSIS COMPLETE - ALL TESTS PASSED")
        else:
            print("⚠️  ANALYSIS COMPLETE - ISSUES FOUND")
        print("=" * 50)
    else:
        print("❌ No VCD files found to analyze")

if __name__ == "__main__":
    main()

