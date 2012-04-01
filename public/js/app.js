var isbnRegex = /^(\w{13}|\w{10})$/;
var userRegex = /^\d{5}$/;
var maxWaitTime = 5;
var waitTime = 0;
var highlightClassNames = {'book': ['active',null,null], 'user': ['done','active',null], 'confirmation': ['done', 'done', 'active']};

var Reservation = Backbone.Model.extend({
  defaults: {
    user: null,
    isbn: null
  },
  validate: function(attrs) {
    if (attrs.isbn && !isbnRegex.test(attrs.isbn))
      return "Sorry! I am not able to recognize the book";
    else if (attrs.user && !userRegex.test(attrs.user))
      return "Sorry! I don't know whom you are, please contact admin.";
  },
  read: function() {
    this.trigger("read");
  }
});

var AlertView = Backbone.View.extend({
  initialize: function(options) {
    this.setElement($(".alert"));
    $(this.el).hide();
    this.model.on("error", $.proxy(this.showAlert, this));
    this.model.on("change", $.proxy(this.hideAlert, this));
  },
  showAlert: function(model, error) {
    $(this.el).fadeIn().html(error);
  },
  hideAlert: function() {
    $(this.el).fadeOut();
  }
})

var ReservationView = Backbone.View.extend({
  initialize: function(options) {
    this.setElement($(".reservation:first"));
    sections = $(this.el).find(".section");
    this.bookEl = this._getElement(sections, "book");
    this.userEl = this._getElement(sections, "user");
    this.confirmationEl = this._getElement(sections, "confirmation");
    this.model.on("read", $.proxy(this.reset, this));
    this.model.on("error", $.proxy(this.clearInput, this));
    this.model.on("change:isbn", $.proxy(this.promptUserDetails, this));
    this.model.on("change:user", $.proxy(this.showConfirmation, this));
    this._alwaysFocusInput();
  },
  events: {
    "change input.barcode": "save"
  },
  save: function(event) {
    var element = event.target;
    this.model.set($(element).attr("data-input-type"), element.value);
  },
  reset: function() {
    this.model.set({isbn: null, user: null});
    $(this.el).find("input.barcode").val("");
    this.promptBookDetails();
    this._updateWaitTime(100);
    clearInterval(this.timerId);
    waitTime = 0;
  },
  promptBookDetails: function() {
    this.focus(this.bookEl);
    this._highlightHelp();
  },
  promptUserDetails: function() {
    this.focus(this.userEl);
    this._highlightHelp();
  },
  showConfirmation: function() {
    this.focus(this.confirmationEl);
    this.startTimer();
    this._highlightHelp();
  },
  focus: function(section) {
    var deFocusedElements = _.reject([this.userEl, this.bookEl, this.confirmationEl], function(element) { return element == section });
    _.each(deFocusedElements, $.proxy(function(element) { $(element).hide(); }, this));
    $(section).fadeIn();
    $(section).find("input.barcode").focus();
  },
  startTimer: function() {
    this.timerId = setInterval($.proxy(this._updateTime, this), 100);
  },
  clearInput: function() {
    var currentSection = $(this.el).find('.section:visible');
    currentSection.find("input.barcode").val("");
  },
  _getElement: function(elements, cssSelector) {
    return _.find(elements, function(element) { return $(element).hasClass(cssSelector); });
  },
  _updateWaitTime: function(value) {
    $(this.confirmationEl).find(".progress .bar").width(value+'%');
  },
  _updateTime: function() {
    waitTime += 1;
    this._updateWaitTime(100 - waitTime);
    if (waitTime >= 105) {
      clearInterval(this.timerId);
      this.reset();
    }
  },
  _alwaysFocusInput: function() {
    $('body').click(function(element) {
      $(".reservation .section:visible").find("input.barcode").focus();
    });
  },
  _highlightHelp: function() {
    var currentSection = $(this.el).find('.section:visible').attr("data-section-name");
    var sectionClassNames = highlightClassNames[currentSection];
    $(this.el).find(".help .notes").each(function(index, element) {
      $(element).removeClass('active done').addClass(sectionClassNames[index]);
    });
  }
});

function newReservation() {
  reservation = new Reservation();
  view = new ReservationView({model: reservation});
  alert = new AlertView({model: reservation});
  reservation.read();
};

$(function() { newReservation(); });