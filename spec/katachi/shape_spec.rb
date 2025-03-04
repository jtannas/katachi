# frozen_string_literal: true

RSpec.describe Katachi::Shape do
  before { described_class.instance_variable_set :@registered_shapes, {} }

  let(:valid_init_args) { { key: :foo, type: :string } }

  describe ".register_new" do
    it "creates a new shape" do
      expect(described_class.register_new(**valid_init_args)).to be_a Katachi::Shape
    end

    it "rejects registering a duplicate shape key" do
      described_class.register_new(**valid_init_args)
      expect { described_class.register_new(**valid_init_args) }.to raise_error Katachi::DuplicateShapeKey
    end
  end

  describe ".[]" do
    it "allows retrieving shapes from those that are registered" do
      shape = described_class.register_new(**valid_init_args)
      expect(described_class[:foo]).to be shape
    end

    it "throws when trying to access a shape that's not registered" do
      expect { described_class[:foo] }.to raise_error Katachi::MissingShapeKey
    end
  end

  describe "#initialize" do
    it "succeeds with valid required kwargs for the definition and stores extras into `input_definition`" do
      instance = described_class.new(**valid_init_args, pattern: /foo/)
      expect(instance).to have_attributes(
        **valid_init_args,
        input_definition: { pattern: /foo/ }
      )
    end

    it "rejects non-symbol value for 'key'" do
      expect { described_class.new(**valid_init_args, key: "foo") }.to raise_error TypeError
    end

    it "rejects invalid values for 'type'" do
      expect { described_class.new(**valid_init_args, type: "foo") }.to raise_error Katachi::InvalidShapeType
    end
  end

  describe "#validate_shape!" do
    context "with type: :array" do
      # TODO
    end

    context "with type: :boolean" do
      # TODO
    end

    context "with type: :number" do
      # TODO
    end

    context "with type: :object" do
      # TODO
    end

    context "with type: :string" do
      let(:valid_init_args) { super().merge(type: :string) }

      context "with attribute :pattern" do
        it "allows for no pattern to be supplied" do
          shape = described_class.new(**valid_init_args.except(:pattern))
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "allows for nil to be supplied" do
          shape = described_class.new(**valid_init_args, pattern: nil)
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "allows for regex to be supplied" do
          shape = described_class.new(**valid_init_args, pattern: /foo/)
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "forbids for strings to be supplied" do
          shape = described_class.new(**valid_init_args, pattern: "123")
          expect { shape.validate_input_definition! }.to raise_error Katachi::InvalidShapeDefinition
        end
      end

      context "with attribute length" do
        it "allows for no length to be supplied" do
          shape = described_class.new(**valid_init_args.except(:length))
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "allows for nil to be supplied" do
          shape = described_class.new(**valid_init_args, length: nil)
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "allows for integers to be supplied" do
          shape = described_class.new(**valid_init_args, length: 3)
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "allows for ranges to be supplied" do
          shape = described_class.new(**valid_init_args, length: 1...4)
          expect { shape.validate_input_definition! }.not_to raise_error
        end

        it "forbids for strings to be supplied" do
          shape = described_class.new(**valid_init_args, length: "3")
          expect { shape.validate_input_definition! }.to raise_error Katachi::InvalidShapeDefinition
        end
      end
    end
  end
end
