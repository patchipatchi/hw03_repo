import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Starter channel={channel} />, root);
}

class Starter extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
    };

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp) });

  }

  gotView(view) {
    this.setState(view.game);
  }

  restart(view) {
    this.channel.push("restart", {})
      .receive("ok", this.gotView.bind(this));
  }

  guess(_ev) {
    if (this.state.total_guesses % 2 == 1) {
      this.channel.push("guess", _ev.target.id)
        .receive("ok", this.gotView.bind(this));
      console.log("even")
      sleep(1000).then(() => {
        this.channel.push("eval", {})
          .receive("ok", this.gotView.bind(this));
      })
    }
    else {
      this.channel.push("guess", _ev.target.id)
        .receive("ok", this.gotView.bind(this));
    }
  }

  render() {
    console.log("state: ", this.state)

    let html = _.every(this.state.tiles, ["show", true]) ?
      <div>
        <div className="row">
          <div className="column">
            <p>
              <a href="http://saucefed.com">INDEX</a>
            </p>
          </div>
          <div className="column">
            <p>
              <button onClick={this.restart.bind(this)}>RESTART</button>
            </p>
          </div>
          <div className="column">
            <p>
              YOU WON IN {this.state.total_guesses} GUESSES
          </p>
          </div>
        </div>
      </div>
      :
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
              Guesses: {this.state.total_guesses}
            </p>
          </div>
        </div>
        <Grid tiles={this.state.tiles} root={this} />
      </div>
      ;
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
