# frozen_string_literal: true

require "spec_helper"

class Animal
  extend ::CobraCommander::Registry
end

class People
  extend ::CobraCommander::Registry
end

class Dog < Animal[:dog]
end

class Cat < Animal[:cat]
end

RSpec.describe CobraCommander::Registry do
  describe "key" do
    it "carries the key to their instances" do
      expect(Dog.new.key).to eql :dog
      expect(Cat.new.key).to eql :cat
    end

    it "exposes the key on classes" do
      expect(Dog.key).to eql :dog
      expect(Cat.key).to eql :cat
    end
  end

  it "allows creating inheritance based registration to the registry" do
    expect(Animal.all[:dog]).to be Dog
    expect(Animal.all[:cat]).to be Cat
  end

  it "has different registries for defent classes" do
    expect(Animal.all.keys).to eql %i[dog cat]
    expect(People.all).to be_empty
  end
end
