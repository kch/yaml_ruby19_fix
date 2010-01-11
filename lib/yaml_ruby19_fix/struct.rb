#!/usr/bin/env ruby1.9 -ryaml
# encoding: UTF-8

class Struct
  # ruby 1.8 dumps structs as maps with string keys.
  # ruby 1.9 dumps structs as maps with symbol keys.
  # When importing, ruby 1.9 will expect the hash keys to be symbols.
  # This fix envelops Struct::yaml_new to convert the keys in `val`
  # before passing control to the original yaml_new.
  class_def_around :yaml_new, :indifferent_keys do |klass, tag, val|
    symval = val.inject({}) { |h, (k, v)| h[k.to_sym] = v; h }
    yaml_new_without_indifferent_keys(klass, tag, symval)
  end

  # Allow structs with a nameless class to be dumped.
  class_def_around :yaml_tag_class_name, :nameless_struct do
    yaml_tag_class_name_without_nameless_struct if self.name
  end

  # Dump ruby1.8-compatible structs with strings as keys.
  def_around :members, :string_keys_for_to_yaml do |opts = {}|
    members = members_without_string_keys_for_to_yaml
    return members unless caller.first =~ /in to_yaml'$/
    members.map(&:to_s)
  end
end
