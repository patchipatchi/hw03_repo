// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import $ from "jquery";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import socket from "./socket"
import game_init from "./starter-game";

function form_init() {
  let user_id = window.userName;
  $('#game-button').click(() => {
    xx = $('#game-input').val();
    window.location = 'game/' + xx + '?name=' + user_id;
  });
}

function start() {
  let root = document.getElementById('root');
  let user_id = window.userName;
  if (root) {
    socket.connect();
    let channel = socket.channel("games:" + window.gameName, {});
    // We want to join in the react component.
    game_init(root, channel, user_id);
    console.log(window.gameName)
    console.log(user_id)
  }

  if (document.getElementById('game-input')) {
    form_init();
  }
}

$(start);
