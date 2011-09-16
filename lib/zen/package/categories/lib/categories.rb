root = __DIR__('categories')

Ramaze::HelpersHelper.options.paths.push(root)
Ramaze.options.roots.push(root)
Zen::Language.options.paths.push(root)

require __DIR__('categories/model/category_group')
require __DIR__('categories/model/category')
require __DIR__('categories/controller/category_groups')
require __DIR__('categories/controller/categories')
require __DIR__('categories/plugin/categories')

Zen::Language.load('categories')
Zen::Language.load('category_groups')

Zen::Package.add do |p|
  p.name          = 'categories'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = 'Module for managing categories. Categories can be used ' \
    'to organize section entries.'

  p.directory     = __DIR__('categories')
  p.migration_dir = __DIR__('../migrations')

  p.menu = [{
    :title => lang('categories.titles.index'),
    :url   => "admin/category-groups"
  }]

  p.controllers = {
    lang('categories.titles.index')      => Categories::Controller::Categories,
    lang('category_groups.titles.index') => Categories::Controller::CategoryGroups
  }
end

Zen::Plugin.add do |p|
  p.name   = 'categories'
  p.author = 'Yorick Peterse'
  p.url    = 'http://yorickpeterse.com/'
  p.about  = 'Plugin that makes it easier to retrieve categories and ' \
    'category groups.'

  p.plugin = Categories::Plugin::Categories
end
