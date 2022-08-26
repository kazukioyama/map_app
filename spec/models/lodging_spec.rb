require 'rails_helper'

RSpec.describe Lodging, type: :model do
  it "is valid with name" do
    lodging = Lodging.new(name: "ホテルテスト")
    expect(lodging).to be_valid
  end
end
