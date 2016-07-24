class AttributesController < ApplicationController
  def index
    json = Attribute.select(:id, :name, :attribute_type).order(:name).map do |attribute|
      {id: attribute[:id], name: attribute[:name], attribute_type: attribute[:attribute_type], displayName: attribute[:name], attributeType: attribute[:attribute_type]}
    end

    render json: {attributes: json}
  end

  def create
    params[:name] = params[:displayName] if params[:displayName]
    params[:attribute_type] = params[:attributeType] if params[:attributeType]

    use_case = CreateAttribute.new(params[:name], params[:attribute_type])
    if (use_case.run)
      render json: {attribute: use_case.attribute}
    else
      render json: {errors: use_case.errors}, status: :bad_request
    end
  end
end
