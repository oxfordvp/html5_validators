module ActiveModel
  module Validations
    module HelperMethods
      def attribute_required?(object, attribute)
        validator = object.class.validators.grep(PresenceValidator).find { |v| v.attributes.include?(attribute.to_sym) }
        return false unless validator

        if cant_handle_conditions?(validator)
          (validator.options.keys & [:if, :unless]).empty?
        else
          if_condition = if_condition(validator)
          return object.send(if_condition) if can_handle_condition?(if_condition)

          unless_condition = unless_condition(validator)
          return !object.send(unless_condition) if can_handle_condition?(unless_condition)
        end
      end

      def attribute_maxlength(attribute)
        self.validators.grep(LengthValidator).select {|v|
          v.attributes.include?(attribute.to_sym) && (v.options.keys & [:maximum, :is]).any? && (v.options.keys & [:if, :unless, :tokenizer]).empty?
        }.map {|v| v.options.slice(:maximum, :is)}.map(&:values).flatten.max
      end

      def attribute_minlength(attribute)
        self.validators.grep(LengthValidator).select {|v|
          v.attributes.include?(attribute.to_sym) && (v.options.keys & [:minimum, :is]).any? && (v.options.keys & [:if, :unless, :allow_nil, :allow_blank, :tokenizer]).empty?
        }.map {|v| v.options.slice(:minimum, :is)}.map(&:values).flatten.min
      end

      def attribute_max(attribute)
        self.validators.grep(NumericalityValidator).select {|v|
          v.attributes.include?(attribute.to_sym) && (v.options.keys & [:less_than, :less_than_or_equal_to]).any? && (v.options.keys & [:if, :unless, :allow_nil, :allow_blank]).empty?
        }.map {|v| v.options.slice(:less_than, :less_than_or_equal_to)}.map(&:values).flatten.max
      end

      def attribute_min(attribute)
        self.validators.grep(NumericalityValidator).select {|v|
          v.attributes.include?(attribute.to_sym) && (v.options.keys & [:greater_than, :greater_than_or_equal_to]).any? && (v.options.keys & [:if, :unless, :allow_nil, :allow_blank]).empty?
        }.map {|v| v.options.slice(:greater_than, :greater_than_or_equal_to)}.map(&:values).flatten.min
      end

      private

      def unless_condition(validator)
        validator.options[:unless]
      end

      def if_condition(validator)
        validator.options[:if]
      end

      def can_handle_condition?(condition)
        condition.is_a?(Symbol)
      end

      def cant_handle_conditions?(validator)
        !can_handle_condition?(if_condition(validator)) && !can_handle_condition?(unless_condition(validator))
      end
    end
  end
end
