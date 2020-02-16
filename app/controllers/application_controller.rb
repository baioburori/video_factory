# -*- encoding: utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery
   
end

class String
  def truncate(n)
    slice(/^.{0,#{n}}/m) + (nchar > n ? "..." : "")
  end

  def nchar
    split(//).size
  end
end
