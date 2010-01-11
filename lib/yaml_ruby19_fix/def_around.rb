#!/usr/bin/env ruby1.9
# encoding: UTF-8

class Object
  def eigenclass_def_around method_name, feature_name, &method_definition
    class << self; self end.def_around method_name, feature_name, &method_definition
  end

  def eigenclass_around_disable_feature feature_name
    class << self; self end.around_disable_feature feature_name
  end

  alias_method :def_around, :eigenclass_def_around
  alias_method :around_disable_feature, :eigenclass_around_disable_feature
end

class Class
  # Like ActiveSupport's alias_method_chain but with Even Less Typing™
  def def_around method_name, feature_name, &method_definition
    method_name_prefix  = method_name.to_s.sub(/[!?]$/, '')
    method_name_punct   = $&
    method_name_without = [method_name_prefix, '_without_', feature_name, method_name_punct].join
    method_name_with    = [method_name_prefix, '_with_',    feature_name, method_name_punct].join
    define_method method_name_with, &method_definition
    alias_method method_name_without, method_name unless method_defined? method_name_without
    alias_method method_name, method_name_with
  end

  def class_def_around method_name, feature_name, &method_definition
    def_around method_name, feature_name, &method_definition
  end

  alias_method :class_def_around, :eigenclass_def_around
  alias_method :class_around_disable_feature, :eigenclass_around_disable_feature

  def around_disable_feature feature_name
    rx = /^(.+)_without_#{feature_name}([?!])?$/
    instance_methods.select { |m| m =~ rx }.each { |m| alias_method m.to_s.sub(rx, '\\1\\2'), m }
  end
end
