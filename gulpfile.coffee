# Load all required libraries.
gulp          = require 'gulp'
svgo          = require 'gulp-svgo'
iconfont      = require 'gulp-iconfont'
Table         = require 'cli-table2'
fontmin       = require 'gulp-fontmin'
cheerio       = require 'gulp-cheerio'
pug           = require 'gulp-pug'

paths = 
  components: 'build/components'
  sass: 'build/sass/*.sass'
  css: 'web/themes/formaphile/css/'
  res: 'web/themes/formaphile/res/'
  examples: 'web/themes/formaphile/examples/'
  icons: 'build/icons/'
  js: 'web/themes/formaphile/js/'

cleanUpFigmaSVG = ($, file) ->
  
  # replace once reference
  $uses = $ 'use'
  $uses.each ->
    $use = $ @

    transform = $use.attr 'transform'
    selector = $use.attr 'xlink:href'
    $target = $ selector
    $target.attr 'transform', transform

    $use.replaceWith $target

  $ '[figma\\:type]'
    .removeAttr 'figma:type'

  $ '[fill="#FFFFFF"]'
    .remove()

gulp.task 'build', ->

  glyphList = new Array

  options = 
    fontName: 'Geometric Shapes'
    prependUnicode: true
    ascent: 800
    descent: 200
    fontHeight: 1000

  gulp
    .src 'svg/*.svg'
    .pipe cheerio cleanUpFigmaSVG
    .pipe svgo plugins: [
      transformsWithOnePath: yes
      removeEditorsNSData: yes
      removeDesc: yes
      removeTitle: yes
      collapseGroups: yes
    ]
    .pipe gulp.dest 'processed-svg'
    .pipe iconfont options
    .on 'glyphs', (glyphs, options) ->
      console.log 'Create font "' + options.fontName + '"'
      table = new Table('head': [
        'NAME'
        'UNICODE'
      ])
      for index of glyphs
        table.push [
          glyphs[index].name
          glyphs[index].unicode[0]
        ]
        glyphList.push [
          glyphs[index].name
          glyphs[index].unicode[0]
        ]
      console.log table.toString()


      console.log glyphList

      pugOpts = 
        locals:
          glyphs: glyphList 

      gulp
        .src 'demo.pug'
        .pipe pug pugOpts
        .pipe gulp.dest 'demo'

      return
    .pipe gulp.dest 'dist'



gulp.task 'watch', ['build'], ->
  gulp.watch 'svg/*.svg', ['build']
  gulp.watch 'demo.pug', ['build']

# Default task call every tasks created so far.
gulp.task 'default', ['watch']