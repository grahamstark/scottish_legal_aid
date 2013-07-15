#!/usr/bin/ruby
# exe ='../bin/write_model_datasets'
exe ='../bin/sla_server'
ARGV.each{
        |pos|
        command = "addr2line #{pos} --exe=#{exe} --demangle=gnat functions"
        system command
}
