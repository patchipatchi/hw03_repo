import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root) {
  ReactDOM.render(
    <Starter />,
    root
  );
}

class Starter extends React.Component {
  constructor(props) {
    super(props);
    let good_vals = ["A", "B", "C", "D", "E", "F", "G", "H"];
    let actual_good_vals = _.concat(good_vals, good_vals);
    actual_good_vals = _.shuffle(actual_good_vals);
    let new_state = {tiles:
      actual_good_vals.map((value, index)=>
      _.assign({}, {val: value, id: index, show: false})),
      current_guess: [], guesses: 0};
      this.state = (new_state);

    }

    restart(_ev){
      let good_vals = ["A", "B", "C", "D", "E", "F", "G", "H"];
      let actual_good_vals = _.concat(good_vals, good_vals);
      actual_good_vals = _.shuffle(actual_good_vals);
      let new_state = {tiles:
        actual_good_vals.map((value, index)=>
        _.assign({}, {val: value, id: index, show: false})),
        current_guess: [], guesses: 0};
        this.setState(new_state);
      }

      reveal_tile(id){
        let new_state = _.assign({}, this.state, {tiles:
          this.state.tiles.map((tile) =>
          (tile.id == id) ?
          _.assign({}, tile, {show: true}) :
          tile
        )
      },
      {current_guess:
        _.concat(this.state.current_guess, _.find(this.state.tiles, function(o) {return o.id == id}))
      });
      return new_state;

    }



    eval(){
      let new_state = (this.state.current_guess.length > 1)?
      (_.first(this.state.current_guess).val == _.last(this.state.current_guess).val)?
      _.assign({}, this.state, {current_guess: []}) :
      _.assign({}, this.state, {current_guess: []}, {tiles:
        this.state.tiles.map((tile) =>
        (tile.val == _.first(this.state.current_guess).val ||
        tile.val == _.last(this.state.current_guess).val) ?
        _.assign({}, tile, {show: false}):
        tile)}
      ) :
      this.state;

      (this.state.current_guess.length == 2) ?
      sleep(1000).then(() => {
        this.setState(new_state);
      }):
      this.setState(new_state);
    }

    guess(_ev){
      let new_state = _.assign({}, this.reveal_tile(_ev.target.id), {guesses: this.state.guesses + 1});
      this.setState(new_state, this.eval);
    }

    render() {

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
              YOU WON IN {this.state.guesses} GUESSES
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
              Guesses: {this.state.guesses}
            </p>
          </div>
        </div>
        <Grid tiles={this.state.tiles} root={this} />
      </div>
      ;
      return html;
    }
  }

  function Tiler(root, tile){
    return (tile.show == true) ?
    <div className="column">
      <p>
        {tile.val}
      </p>
    </div>
    :
    (root.state.current_guess.length > 1) ?
    <div className="column">
      <p>
        <button>
        </button>
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

  function Grid(params){
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

  // https://zeit.co/blog/async-and-await Guillermo Rauch
  function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
  }

