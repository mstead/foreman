module Api
  module V2
    class SubnetsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, '/subnets', 'List of subnets'
      param :search, String, :desc => 'Filter results'
      param :order, String, :desc => 'Sort results'
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @subnets = Subnet.
          authorized(:view_subnets).
          includes(:tftp, :dhcp, :dns).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/subnets/:id/", "Show a subnet."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :subnet do
        param :subnet, Hash, :action_aware => true do
          param :name, String, :desc => 'Subnet name', :required => true
          param :network, String, :desc => 'Subnet network', :required => true
          param :mask, String, :desc => 'Netmask for this subnet', :required => true
          param :gateway, String, :desc => 'Primary DNS for this subnet'
          param :dns_primary, String, :desc => 'Primary DNS for this subnet'
          param :dns_secondary, String, :desc => 'Secondary DNS for this subnet'
          param :from, String, :desc => 'Starting IP Address for IP auto suggestion'
          param :to, String, :desc => 'Ending IP Address for IP auto suggestion'
          param :vlanid, String, :desc => 'VLAN ID for this subnet'
          param :domain_ids, Array, :desc => 'Domains in which this subnet is part'
          param :dhcp_id, :number, :desc => 'DHCP Proxy to use within this subnet'
          param :tftp_id, :number, :desc => 'TFTP Proxy to use within this subnet'
          param :dns_id, :number, :desc => 'DNS Proxy to use within this subnet'
        end
      end

      api :POST, '/subnets', 'Create a subnet'
      param_group :subnet, :as => :create

      def create
        @subnet = Subnet.new(params[:subnet])
        process_response @subnet.save
      end

      api :PUT, '/subnets/:id', 'Update a subnet'
      param :id, :number, :desc => 'Subnet numeric identifier', :required => true
      param_group :subnet

      def update
        process_response @subnet.update_attributes(params[:subnet])
      end

      api :DELETE, '/subnets/:id', 'Delete a subnet'
      param :id, :number, :desc => 'Subnet numeric identifier', :required => true

      def destroy
        process_response @subnet.destroy
      end

    end
  end
end
