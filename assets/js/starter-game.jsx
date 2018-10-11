import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel, user_id) {
  ReactDOM.render(<Starter channel={channel} user_id={user_id} />, root);
}

class Starter extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.user_id = props.user_id;
    this.state = {};

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp) });


    this.channel.on("update_view", game_state => {
      console.log("update")
      console.log(game_state)
      this.setState(game_state)
    })
  }
  gotView(view) {
    this.setState(view.game);
  }

  restart(view) {
    if (this.user_id == this.state.player1_name || this.user_id == this.state.player2_name) {
      this.channel.push("restart", {})
        .receive("ok", this.gotView.bind(this));
    } else {
      return
    }
  }

  guess(_ev) {
    if (this.state.total_guesses % 2 == 1) {
      this.channel.push("guess", { id: _ev.target.id, user: this.user_id })
        .receive("ok", this.gotView.bind(this));
      console.log("even")
      sleep(1000).then(() => {
        this.channel.push("eval", {})
          .receive("ok", this.gotView.bind(this));
      })
    }
    else {
      this.channel.push("guess", { id: _ev.target.id, user: this.user_id })
        .receive("ok", this.gotView.bind(this));
    }
  }

  isWinner() {
    if (this.state.player1_points > this.state.player2_points) {
      return this.state.player1_name + " wins!";
    }
    else if (this.state.player1_points < this.state.player2_points) {
      return this.state.player2_name + " wins!";
    }
    else {
      return this.state.player1_name + " and " + this.state.player2_name + " wins!";
    }
  }

  render() {
    console.log("state: ", this.state)

    var html = []
    if (this.state.player_number < 2) {
      html.push(
        <div>
          <p>In game lobby. Waiting for other player.</p>
        </div>
      );
    }
    else if (_.every(this.state.tiles, ["show", true])) {
      html.push(
        <div>
          <div className="row">
            <div className="column">
              <p>
                <a href="http://saucefed.com">INDEX</a>
              </p>
            </div>
            <div className="column">
              <p>
                <button onClick={this.restart.bind(this)}>GAME LOBBY</button>
              </p>
            </div>
            <div className="column">
              <p>
                {this.isWinner()}
              </p>
            </div>
          </div>
        </div>
      );
    }
    else {
      html.push(
        <div>
          <div className="row">
            <div className="column">
              <p>
                <button onClick={this.restart.bind(this)}>RESTART</button>
              </p>
            </div>
            <div className="column">
              <p>
                <a href="http://saucefed.com">INDEX</a>
              </p>
            </div>
            <div className="column">
              <p>
                {this.state.player1_name}'s Points: {this.state.player1_points}
              </p>
            </div>
            <div className="column">
              <p>
                {this.state.player2_name}'s Points: {this.state.player2_points}
              </p>
            </div>
          </div>
          <Grid tiles={this.state.tiles} root={this} />
        </div>
      );
    }

    return html;
  }
}

function Grid(params) {
  let t = _.curry(Tiler)
  let root_Tiler = t(params.root)

  return <div>
    <div className="row">
      {_.map(_.slice(params.tiles, 0, 4), root_Tiler)}
    </div>
    <div className="row">
      {_.map(_.slice(params.tiles, 4, 8), root_Tiler)}
    </div>
    <div className="row">
      {_.map(_.slice(params.tiles, 8, 12), root_Tiler)}
    </div>
    <div className="row">
      {_.map(_.slice(params.tiles, 12, 16), root_Tiler)}
    </div>
  </div>;
}

function Tiler(root, tile) {
  return (tile.show == true) ?
    <div className="column">
      <p>
        {tile.val}
      </p>
    </div>
    :
    <div className="column">
      <p>
        <button
          id={tile.id}
          onClick={root.guess.bind(root)}>
        </button>
      </p>
    </div>
}

// https://zeit.co/blog/async-and-await Guillermo Rauch
function sleep(time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}
