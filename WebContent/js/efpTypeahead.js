/*How to use the searchBox
 * 
 * function definition
 *  startSearchBox(input, dataSource, target, showWaitIconAhead, delay) 
 *  @param input the input box you want to inject
 *  @param dataSource: 1. a string Array ["aaaa","bbbb"]
 *      2. a item Array, item is an object with three field: id, text, and category [{id:1, text:"the text to display", category:"warning"}]
 *      3. a restful server, for example: 'rest/search-vendor'. the request will be sent as 'rest/search-vendor/{query}'. receving a JSON 
 *  @target a string to navigator to, eg: somewhere?id=@id. Or a function with a param item{id, text, category}
 *  @param showWaitIconAhead if true the wait icon will show before the input
 *  @param delay the ms delay to display. default 700 !BUT the delay will not working if dataSource is an Array or Object!!!
 * 
Example 1, search string locally startSearchBox($("input[name=query]"), ["This is the first string", "this is the second string"], function(item) {
        alert(item.text || item);
    });
    
Example 2, search locally with category
    startSearchBox($("input[name=query]"), [{id:1, text:"the text to display", category:"warning"},{id:3, text:"third text to display", category:"warning"},{id:2, text:"second text to display", category:"notification"}], function(item) {
        alert(item.text || item);
    });
    
Example 3, 
     startSearchBox($("input[name=query]"), "somewhere-to-search-data", function(item) {
        alert(item.text || item);
    });
*/

/* =============================================================
 * Enhancement of bootstrap-typeahead.js v2.3.1
 * https://github.com/runzhi/bootstrap-categoryTypeahead
 * http://twitter.github.com/bootstrap/javascript.html#typeahead
 * =============================================================
 */
! function($) {"use strict";// jshint ;_;

    /* TYPEAHEAD PUBLIC CLASS DEFINITION
     * ================================= */

    var Typeahead = function(element, options) {
        this.$element = $(element)
        this.options = $.extend({}, $.fn.efpTypeahead.defaults, options)
        this.matcher = this.options.matcher || this.matcher
        this.sorter = this.options.sorter || this.sorter
        this.highlighter = this.options.highlighter || this.highlighter
        this.updater = this.options.updater || this.updater
        this.source = this.options.source
        this.$menu = $(this.options.menu)
        this.shown = false
        this.listen()
    }

    Typeahead.prototype = {

        constructor : Typeahead,
        select : function() {
            var selected_element = this.$menu.find('.active');

            var item = {
                id : selected_element.attr('data-value'),
                text : selected_element.attr('text-value'),
                category : selected_element.attr('category-value')
            }
            this.$element.val(this.updater(item)).change()
            return this.hide()
        },
        updater : function(item) {
            return item.text || item
        },
        show : function() {
            var pos = $.extend({}, this.$element.position(), {
                height : this.$element[0].offsetHeight
            })

            this.$menu.insertAfter(this.$element).css({
                top : pos.top + pos.height,
                left : pos.left
            }).show()

            this.shown = true
            return this
        },
        hide : function() {
            this.$menu.hide()
            this.shown = false
            return this
        },
        lookup : function(event) {
            var items

            this.query = this.$element.val()

            if (!this.query || this.query.length < this.options.minLength) {
                return this.shown ? this.hide() : this
            }

            items = $.isFunction(this.source) ? this.source(this.query, $.proxy(this.process, this)) : this.source

            return items ? this.process(items) : this
        },
        process : function(items) {
            var that = this
            var categorys = []
            !$.isFunction(this.source) && (items = $.grep(items, function(item) {
                return that.matcher(item)
            }))
            for (var i = 0; i < items.length; i++) {
                var item = items[i]
                item.category && !~$.inArray(item.category, categorys) && categorys.push(item.category);
            };
            categorys = categorys.sort();

            var category;
            var result = [];
            if(categorys.length == 0){
                result = this.sorter(items);
            }
            else{
                while ( category = categorys.shift()) {
                    var sortItems = []
                    for (var i = 0; i < items.length; i++) {
                        var item = items[i]
                        item.category == category && sortItems.push(item);
                    }
                    sortItems = this.sorter(sortItems);
                    result = result.concat(sortItems);
                }

            }
            if (!result.length) {
                return this.shown ? this.hide() : this
            }

            return this.render(result.slice(0, this.options.items)).show()
        },
        matcher : function(item) {
            return item.text ? ~item.text.toLowerCase().indexOf(this.query.toLowerCase()) : ~item.toLowerCase().indexOf(this.query.toLowerCase());
        },
        sorter : function(items) {
            var beginswith = [], caseSensitive = [], caseInsensitive = [], item, categorys = []
            while ( item = items.shift()) {
                if (item.text ? !item.text.toLowerCase().indexOf(this.query.toLowerCase()) : !item.toLowerCase().indexOf(this.query.toLowerCase()))
                    beginswith.push(item)
                else if (item.text ? ~item.text.indexOf(this.query) : item.indexOf(this.query) )
                    caseSensitive.push(item)
                else
                    caseInsensitive.push(item)
            }

            return beginswith.concat(caseSensitive, caseInsensitive)
        },
        highlighter : function(item) {
            var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
            if (item.text) {
                return item.text.replace(new RegExp('(' + query + ')', 'ig'), function($1, match) {
                    return '<strong>' + match + '</strong>'
                })
            } else {
                return item.replace(new RegExp('(' + query + ')', 'ig'), function($1, match) {
                    return '<strong>' + match + '</strong>'
                })
            }

        },
        render : function(items) {
            var that = this
            var previous_category;
            items = $(items).map(function(i, item) {
                i = $(that.options.item).attr('data-value', item.id || item).attr('text-value', item.text || item).attr("category-value", item.category)
                i.find('a').html(that.highlighter(item.text || item)).css("display", "inline");
                if (item.category) {
                    if (!previous_category) {
                        i.find('span').html(item.category).css("float", 'right').css('color', '#999999').css('margin', '0 10px 0 0');
                    } else if (item.category != previous_category) {
                        var $container =$("<div>");
                        var hr = $("<hr/>").css('margin', '10px 0');
                        i.find('span').html(item.category).css("float", 'right').css('color', '#999999').css('margin', '0 10px 0 0');
                        $container.append(hr);
                        $container.append(i);
                        i = $($container.html());
                    }
                    previous_category = item.category;
                }

                return i.get()
            })

            items.first().addClass('active')
            this.$menu.html(items)
            return this
        }
 , next: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , next = $(active.nextAll('li')[0])

      if (!next.length) {
        next = $(this.$menu.find('li')[0])
      }

      next.addClass('active')
    }

  , prev: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , prev = $(active.prevAll('li')[0])

      if (!prev.length) {
        prev = this.$menu.find('li').last()
      }

      prev.addClass('active')
    }

  , listen: function () {
      this.$element
        .on('blur',     $.proxy(this.blur, this))
        .on('keypress', $.proxy(this.keypress, this))
        .on('keyup',    $.proxy(this.keyup, this))

      if ($.browser && ($.browser.chrome || $.browser.webkit || $.browser.msie)) {
        this.$element.on('keydown', $.proxy(this.keydown, this))
      }

      this.$menu
        .on('click', $.proxy(this.click, this))
        .on('mouseenter', 'li', $.proxy(this.mouseenter, this))
    }

  , move: function (e) {
      if (!this.shown) return

      switch(e.keyCode) {
        case 9: // tab
        case 13: // enter
        case 27: // escape
          e.preventDefault()
          break

        case 38: // up arrow
          e.preventDefault()
          this.prev()
          break

        case 40: // down arrow
          e.preventDefault()
          this.next()
          break
      }

      e.stopPropagation()
    }

  , keydown: function (e) {
      this.suppressKeyPressRepeat = !~$.inArray(e.keyCode, [40,38,9,13,27])
      this.move(e)
    }

  , keypress: function (e) {
      if (this.suppressKeyPressRepeat) return
      this.move(e)
    }

  , keyup: function (e) {
      switch(e.keyCode) {
        case 40: // down arrow
        case 38: // up arrow
          break

        case 9: // tab
        case 13: // enter
          if (!this.shown) return
          this.select()
          break

        case 27: // escape
          if (!this.shown) return
          this.hide()
          break

        default:
          this.lookup()
      }

      e.stopPropagation()
      e.preventDefault()
  }

  , blur: function (e) {
      var that = this
      setTimeout(function () { that.hide() }, 150)
    }

  , click: function (e) {
      e.stopPropagation()
      e.preventDefault()
      this.select()
    }

  , mouseenter: function (e) {
      this.$menu.find('.active').removeClass('active')
      $(e.currentTarget).addClass('active')
    }

  }

    /* TYPEAHEAD PLUGIN DEFINITION
     * =========================== */

    var old = $.fn.efpTypeahead

    $.fn.efpTypeahead = function(option) {
        return this.each(function() {
            var $this = $(this), data = $this.data('typeahead'), options = typeof option == 'object' && option
            if (!data)
                $this.data('typeahead', ( data = new Typeahead(this, options)))
            if ( typeof option == 'string')
                data[option]()
        })
    }

    $.fn.efpTypeahead.defaults = {
        source : [],
        items : 8,
        menu : '<ul class="typeahead efp-drop-menu"></ul>',
        item : '<li><a href="#"></a><span></span></li>',
        minLength : 1
    }
    $.fn.efpTypeahead.Constructor = Typeahead

    /* TYPEAHEAD NO CONFLICT
     * =================== */

    $.fn.efpTypeahead.noConflict = function() {
        $.fn.efpTypeahead = old
        return this
    }
    /* TYPEAHEAD DATA-API
     * ================== */

    // $(document).on('focus.typeahead.data-api', '[data-provide="typeahead"]', function(e) {
        // var $this = $(this)
        // if ($this.data('typeahead'))
            // return $this.typeahead($this.data())
    // })
}(window.jQuery);


/**
 *input: the input box to hook
 *dataSource: the data source to fetch data, which accept a string param "query", or a array for static resources and a link for dynamic resources
 *target: when click a result, action: a function for a callback result, or a link to with param $id to navigate, or leave empty to use default behavior which is using result to fill the searchBox
 */
var startSearchBox = function(input, dataSource, target, showWaitIconAhead, delay) {
    if (delay == undefined || delay == null)
        delay = 700;
    var timeoutId = null;
    var waitBox = $('<img alt="Loading" src="/efp/images/loader.gif" style = "display:inline"/>');
    if(showWaitIconAhead){
        $(input).before(waitBox);
    }else{
        $(input).after(waitBox);
    }
    
    $(input).efpTypeahead({
        "source" :typeof(dataSource) == "string" ? function(query, process) {
            if (timeoutId) {
                clearTimeout(timeoutId);
            }

            timeoutId = setTimeout(function() {
                updateBox(query, process);

            }, delay)
           
        } :dataSource,

        "updater" : function(item) {
            if ( typeof (target) == 'function') {
                target(item);
                return;
            } else if ( typeof (target) == "string") {
                var url = target.replace("$id", item);
                location.href = url;
                return item;
            }
            
        },
        "minLength" : 1
    });

    var updateBox = function(query, process) {
        showWait();
        var result = [];
         if ( typeof (dataSource) == "string") {
            
            var url = dataSource + "/" + query;
            $.getJSON(url, function(data) {
                process(data);
                clearWait();
            });
            return;
        }

        process(dataSource);
        clearWait();
    }
    var showWait = function() {
        waitBox.css("visibility","visible");
    }
    var clearWait = function() {
        waitBox.css("visibility","hidden");
    }
    clearWait();
}



