require 'rails_helper'

RSpec.describe ExcelHandler, type: :model do
	it 'instance.model should be a class' do
		excel = ExcelHandler.new(model: User)

		expect(excel.model).to be(User)
	end

	it 'should exclude default excluded columns' do
		excel = ExcelHandler.new(model: User)

		condition = false

		excel.possible_columns.each do |column|
			condition = true if excel.default_excluded_columns.include?(column)
		end

		expect(condition).to eq(false)
	end

	it 'should select columns within possible_columns' do
		excel = ExcelHandler.new(model: User)

		columns = [excel.possible_columns.first, 'lorem_ipsum_dolor_amet']

		excel.select_columns(columns)

		expect(excel.columns).to eq([columns.first])
	end

	it 'should use the parameters to get the columns' do
		excel = ExcelHandler.new model: User
<<<<<<< HEAD
		params = ActionController::Parameters.new({ filter: { "Lot"=> "1", 
																												  "Name"=> "1"}, 
																								order: "Name" })

		excel.get_rows(params, :filter)

		expect(excel.columns).to eq(['Lot', 'Name'])
=======
		params = ActionController::Parameters.new({ "Lot"=> true, "Name"=>true })

		excel.get_rows(params)
>>>>>>> 0bd664f7e088d1ee05a0be1275ab0d36dbcce97a
	end
end