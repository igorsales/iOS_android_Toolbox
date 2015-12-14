require 'spec_helper'

include IosAndroidToolbox

describe 'iOS versioning', :type => :model do
	before :all do

	end

	before :each do
		@controller = IosVersionController.new(File.join(File.dirname(__FILE__),'fixtures','info1.plist'))
	end

	it 'should read the right version number' do
		expect(@controller.version).to eq '1.2.3-4'
	end

	it 'increments the build number on next version' do
		expect(@controller.next_build_number!).to eq '1.2.3-5'
		expect(@controller.version).to eq '1.2.3-5'
	end
end