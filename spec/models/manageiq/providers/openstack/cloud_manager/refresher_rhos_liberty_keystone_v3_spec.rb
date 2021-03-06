require_relative "refresh_spec_common"

describe ManageIQ::Providers::Openstack::CloudManager::Refresher do
  include Openstack::RefreshSpecCommon

  before(:each) do
    setup_ems('11.22.33.44', 'password_2WpEraURh', 5000, "admin", "v3", "default")
    @environment = :liberty_keystone_v3
  end

  it "will perform a full refresh against RHOS #{@environment}" do
    2.times do # Run twice to verify that a second run with existing data does not change anything
      with_cassette(@environment, @ems) do
        EmsRefresh.refresh(@ems)
        EmsRefresh.refresh(@ems.network_manager)
      end

      assert_common
    end
  end

  context "when configured with skips" do
    before(:each) do
      stub_settings(
        :ems_refresh => {:openstack => {:inventory_ignore => [:cloud_volumes, :cloud_volume_snapshots]}}
      )
    end

    it "will not parse the ignored items" do
      with_cassette(@environment, @ems) do
        EmsRefresh.refresh(@ems)
        EmsRefresh.refresh(@ems.network_manager)
      end

      assert_with_skips
    end
  end
end
