require File.dirname(__FILE__) + "/../spec_helper"

class QrEncoderTestClass
  include QrEncoder
end

describe QrEncoder do
  describe 'qrencode' do
    before do 
      @qr = QrEncoderTestClass.new
    end
    it 'makes a system call to qrencode' do
      @qr.expects(:system).with("qrencode -s 10 -o this \"that\"")
      @qr.qrencode 'this', 'that'
    end
    it 'makes a system call to qrencode' do
      @qr.expects(:system).with("qrencode -s 5 -o this \"that\"")
      @qr.qrencode 'this', 'that', 5
    end
  end
end
