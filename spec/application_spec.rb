require 'spec_helper'
require 'ci_status'

describe "Application" do
  describe "config/app_config.yml" do
    it "should fail when the file does not exist" do
      File.should_receive(:read).with('config/app_config.yml').and_raise(Errno::ENOENT.new)
      get '/'
      expect(last_response.body).to eq("Please create a config/app_config.yml file")
      expect(last_response.status).to eq(500)
    end

    it "should fail when the file is empty" do
      File.should_receive(:read).with('config/app_config.yml').and_return("")
      get '/'
      expect(last_response.status).to eq(422)
    end

    it "should generate a list of ci servers when a valid yaml file is supplied" do
      File.should_receive(:read).with('config/app_config.yml').and_return("- type: 'abd'")
      cc = double(CiStatus::CruiseControl)
      cc.should_receive(:projects).and_return([])
      CiStatus::CruiseControl.should_receive(:new).and_return(cc)
      get '/'
      expect(last_response).to be_ok
    end

    it "should fail when the file content is invalid" do
      File.should_receive(:read).with('config/app_config.yml').and_return("foo:\nbar")
      get '/'
      expect(last_response.body).to eq("Could not parse the supplied yaml file")
      expect(last_response.status).to eq(500)
    end
  end

  describe "CruiseControl" do
    it "should create a CruiseControl object with the right url" do
      ci_servers = [
        {"type" => 'Snap', "url" => 'abc'},
        {"type" => 'Snap', "url" => 'def'}
      ]
      app.any_instance.stub(:ci_servers).and_return(ci_servers)
      cc = double(CiStatus::CruiseControl)
      cc.should_receive(:projects).exactly(2).times.and_return([])
      CiStatus::CruiseControl.should_receive(:new).with('abc', nil, nil).and_return(cc)
      CiStatus::CruiseControl.should_receive(:new).with('def', nil, nil).and_return(cc)
      get '/'
      expect(last_response).to be_ok
    end

    it "should accept user name and password" do
      ci_servers = [
        {"type" => 'Snap', "url" => 'abc'},
        {"type" => 'Go', "url" => 'def', "username" => 'akshay', "password" => 'password'}
      ]
      app.any_instance.stub(:ci_servers).and_return(ci_servers)
      cc = double(CiStatus::CruiseControl)
      cc.should_receive(:projects).exactly(2).times.and_return([])
      CiStatus::CruiseControl.should_receive(:new).with('abc', nil, nil).and_return(cc)
      CiStatus::CruiseControl.should_receive(:new).with('def', 'akshay', 'password').and_return(cc)
      get '/'
      expect(last_response).to be_ok
    end
  end
end