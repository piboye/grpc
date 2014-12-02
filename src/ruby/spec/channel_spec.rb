# Copyright 2014, Google Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'grpc'
require 'port_picker'

module GRPC

  describe Channel do

    before(:each) do
      @cq = CompletionQueue.new
    end

    describe '#new' do

      it 'take a host name without channel args' do
        expect { Channel.new('dummy_host', nil) }.not_to raise_error
      end

      it 'does not take a hash with bad keys as channel args' do
        blk = construct_with_args(Object.new => 1)
        expect(&blk).to raise_error TypeError
        blk = construct_with_args(1 => 1)
        expect(&blk).to raise_error TypeError
      end

      it 'does not take a hash with bad values as channel args' do
        blk = construct_with_args(:symbol => Object.new)
        expect(&blk).to raise_error TypeError
        blk = construct_with_args('1' => Hash.new)
        expect(&blk).to raise_error TypeError
      end

      it 'can take a hash with a symbol key as channel args' do
        blk = construct_with_args(:a_symbol => 1)
        expect(&blk).to_not raise_error
      end

      it 'can take a hash with a string key as channel args' do
        blk = construct_with_args('a_symbol' => 1)
        expect(&blk).to_not raise_error
      end

      it 'can take a hash with a string value as channel args' do
        blk = construct_with_args(:a_symbol => '1')
        expect(&blk).to_not raise_error
      end

      it 'can take a hash with a symbol value as channel args' do
        blk = construct_with_args(:a_symbol => :another_symbol)
        expect(&blk).to_not raise_error
      end

      it 'can take a hash with a numeric value as channel args' do
        blk = construct_with_args(:a_symbol => 1)
        expect(&blk).to_not raise_error
      end

      it 'can take a hash with many args as channel args' do
        args = Hash[127.times.collect { |x| [x.to_s, x] } ]
        blk = construct_with_args(args)
        expect(&blk).to_not raise_error
      end

    end

    describe '#create_call' do
      it 'creates a call OK' do
        port = find_unused_tcp_port
        host = "localhost:#{port}"
        ch = Channel.new(host, nil)

        deadline = Time.now + 5
        expect(ch.create_call('dummy_method', 'dummy_host', deadline))
          .not_to be(nil)
      end

      it 'raises an error if called on a closed channel' do
        port = find_unused_tcp_port
        host = "localhost:#{port}"
        ch = Channel.new(host, nil)
        ch.close

        deadline = Time.now + 5
        blk = Proc.new do
          ch.create_call('dummy_method', 'dummy_host', deadline)
        end
        expect(&blk).to raise_error(RuntimeError)
      end

    end

    describe '#destroy' do
      it 'destroys a channel ok' do
        port = find_unused_tcp_port
        host = "localhost:#{port}"
        ch = Channel.new(host, nil)
        blk = Proc.new { ch.destroy }
        expect(&blk).to_not raise_error
      end

      it 'can be called more than once without error' do
        port = find_unused_tcp_port
        host = "localhost:#{port}"
        ch = Channel.new(host, nil)
        blk = Proc.new { ch.destroy }
        blk.call
        expect(&blk).to_not raise_error
      end
    end

    describe '#close' do
      it 'closes a channel ok' do
        port = find_unused_tcp_port
        host = "localhost:#{port}"
        ch = Channel.new(host, nil)
        blk = Proc.new { ch.close }
        expect(&blk).to_not raise_error
      end

      it 'can be called more than once without error' do
        port = find_unused_tcp_port
        host = "localhost:#{port}"
        ch = Channel.new(host, nil)
        blk = Proc.new { ch.close }
        blk.call
        expect(&blk).to_not raise_error
      end
    end

    def construct_with_args(a)
      Proc.new {Channel.new('dummy_host', a)}
    end

  end

end