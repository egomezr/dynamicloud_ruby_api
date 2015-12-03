# This class maintains properties about api configuration.
# @author Eleazar Gomez
# @version 1.0.0
# @since 8/23/15
class Configuration

  def get_property(property)
    @config[property]
  end

  # Load the current properties in config.yml.
  def initialize
    @config = {
        :url => 'http://api.dynamicloud.org',
        # this url must be executed using post method
        :url_get_records => '/api_models/{csk}/{aci}/get_records/{mid}/{count}/{offset}/',
        # this url must be executed using post method
        :url_get_specific_fields => '/api_models/{csk}/{aci}/get_records_by_projection/{mid}/{count}/{offset}/',
        # this url must be executed using post method
        :url_get_record_info => '/api_records/{csk}/{aci}/get_record_info/{mid}/{rid}',
        # this url must be executed using post method
        :url_update_record => '/api_records/{csk}/{aci}/update_record/{mid}/{rid}',
        # this url must be executed using post method
        :url_save_record => '/api_records/{csk}/{aci}/create_record/{mid}',
        # this url must be executed using delete method
        :url_delete_record => '/api_records/{csk}/{aci}/delete_record/{mid}/{rid}',
        # this url must be executed using get method
        :url_get_model_info => '/api_models/{csk}/{aci}/get_model_info/{mid}',
        # this url must be executed using get method
        :url_get_models => '/api_models/{csk}/{aci}/get_models',
        # this url must be executed using get method
        :url_get_fields => '/api_models/{csk}/{aci}/get_fields/{mid}',
        # this url must be executed using post method
        :url_upload_file => '/api_records/{csk}/{aci}/upload_file_record/{mid}/{rid}',
        # this url must be executed using get method
        :url_download_file => '/api_records/{csk}/{aci}/download_file_record/{mid}/{rid}/{identifier}',
        # this url must be executed using get method
        :url_share_file => '/api_records/{csk}/{aci}/share_file_record/{mid}/{rid}/{identifier}',
        # this url must be executed using post method
        :url_update_selection => '/api_records/{csk}/{aci}/update_using_selection/{mid}',
        # this url must be executed using post method
        :url_delete_selection => '/api_records/{csk}/{aci}/delete_using_selection/{mid}',
        :version => '1.0.4'
    }
  end

  PROPERTIES = Configuration.new
end