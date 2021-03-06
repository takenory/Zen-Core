require File.expand_path('../../../helper', __FILE__)

describe 'Ramaze::Helper::Breadcrumb' do
  extend Ramaze::Helper::Breadcrumb

  it 'Build a set of breadcrumbs' do
    respond_to?('set_breadcrumbs').should == true
    respond_to?('get_breadcrumbs').should == true

    set_breadcrumbs('foo', 'bar', 'baz')

    breadcrumbs = get_breadcrumbs

    breadcrumbs.include?('foo').should == true
    breadcrumbs.include?('bar').should == true
    breadcrumbs.include?('baz').should == true
    breadcrumbs.include?('/').should   == true
  end

  it 'Build a set of breadcrumbs with a custom separator' do
    respond_to?('set_breadcrumbs').should == true
    respond_to?('get_breadcrumbs').should == true

    set_breadcrumbs('foo', 'bar', 'baz')

    breadcrumbs = get_breadcrumbs('--')

    breadcrumbs.include?('foo').should == true
    breadcrumbs.include?('bar').should == true
    breadcrumbs.include?('baz').should == true
    breadcrumbs.include?('--').should == true
  end
end
