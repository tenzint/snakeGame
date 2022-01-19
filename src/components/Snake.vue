<script setup lang="ts">
import { ref, onMounted } from "vue";
let canvasRef = ref<HTMLCanvasElement | null | undefined>(null);
let titleRef = ref<HTMLDivElement | null>(null);
let containerRef = ref<HTMLDivElement | null>(null);
let pausePlay = ref<string>("");
let self: SnakeGame;
let score = ref<number>(0);
let dialog = ref<boolean>(false);
interface Position {
  x: number;
  y: number;
}
let highscore = ref<number>(0);
class SnakeGame {
  cRef: HTMLCanvasElement | null | undefined;
  ctx: CanvasRenderingContext2D | null;
  unit: number;
  width: number;
  height: number;
  canvasColor: string;
  color2: string;
  snakeColor: string;
  foodColor: string;
  snake: Position[];
  velocity: Position;
  timer: number;
  food: Position;
  score: number;
  playingMode: boolean;
  constructor(
    unit = 20,
    width = window.innerWidth / 20,
    height = window.innerHeight / 20
  ) {
    self = this;
    this.cRef = canvasRef.value;
    this.ctx = null;
    this.unit = unit;
    this.width = width;
    this.height = height;
    this.canvasColor = "rgba(128, 128, 128, 0.3)";
    this.color2 = "rgba(128, 128, 128, 0.5)";
    this.snakeColor = "#1B5E20";
    this.foodColor = "#ff0000";
    this.snake = [];
    this.velocity = { x: 1, y: 0 };
    this.timer = 0;
    this.food = { x: Math.random() * this.width, y: Math.random() * this.height };
    this.score = 0;
    this.playingMode = false;
    pausePlay.value = "Pause";
  }
  setup(): Promise<void> {
    return new Promise((res, rej) => {
      if (window.innerWidth >= 1080) this.unit = 40;
      else if (window.innerWidth >= 720) this.unit = 30;
      else this.unit = 20;
      containerRef.value!.style.height =
        window.innerHeight - titleRef.value!.offsetHeight + "px";

      let widthRatio = 1;
      if (window.innerWidth >= 600) widthRatio = 0.8;
      this.cRef!.width =
        Math.floor((window.innerWidth * widthRatio) / this.unit) * this.unit;
      this.cRef!.height =
        Math.floor((window.innerHeight - titleRef.value!.offsetHeight - 10) / this.unit) *
        this.unit;
      this.width = Math.floor(this.cRef!.width / this.unit);
      this.height = Math.floor(this.cRef!.height / this.unit);
      return res();
    });
  }
  async restart(): Promise<void> {
    // keep code dry. Some restart codes here
    if (highscore.value < score.value) {
      highscore.value = score.value;
    }
    this.cleanTimer();
    this.playingMode = false;
    pausePlay.value = "Pause";
    await this.start();
  }
  async start(): Promise<void> {
    await this.setup();
    let halfW = Math.floor(this.width / 2);
    let halfH = Math.floor(this.height / 2);
    this.snake = [];
    this.velocity = { x: 1, y: 0 };
    this.food = { x: Math.random() * this.width, y: Math.random() * this.height };
    this.snake.push({ x: halfW, y: halfH });
    this.snake.push({ x: halfW - 1, y: halfH });
    this.snake.push({ x: halfW - 2, y: halfH });
    this.snake.push({ x: halfW - 3, y: halfH });
    this.updateScore();
    this.randomizeFood();
    this.draw();
  }
  cleanTimer(): void {
    clearInterval(this.timer);
  }
  togglePausePlay(): void {
    if (this.timer) this.cleanTimer();
    if (this.playingMode) {
      // Playing; pause the game
      this.playingMode = false;
      pausePlay.value = "Pause";
    } else {
      // Paused; play the game
      this.playingMode = true;
      pausePlay.value = "Play";
      this.timer = setInterval(() => this.moveNext(), 100);
    }
  }
  updateScore(): void {
    this.score = this.snake.length * 10 - 40;
    score.value = this.score;
  }
  didSnakeEat(): boolean {
    if (this.snake[0].x === this.food.x && this.snake[0].y === this.food.y) {
      this.randomizeFood();
      this.updateScore();
      return true;
    } else return false;
  }
  checkForMistakes(): void {
    if (
      this.snake[0].x < 0 ||
      this.snake[0].x >= this.width ||
      this.snake[0].y < 0 ||
      this.snake[0].y >= this.height
    ) {
      // snake is outside of our canvas
      // Game over!
      this.restart();
      return;
    }
    this.snake.forEach((snakePart) => {
      if (this.snake[0] === snakePart) {
        // found the snake head itself -> ignore
        return;
      }
      if (this.snake[0].x === snakePart.x && this.snake[0].y === snakePart.y) {
        this.restart();
        return;
      }
    });
  }
  moveNext(): void {
    let newSnakePos: Position = { x: this.snake[0].x, y: this.snake[0].y };
    newSnakePos.x += this.velocity.x;
    newSnakePos.y += this.velocity.y;
    this.snake.unshift(newSnakePos);
    this.checkForMistakes();

    let ate = this.didSnakeEat();
    if (!ate) this.snake.pop();
    this.draw();
  }
  /*----------------------------------------------------------------
   * Instead of checking for `velocity.x/y`,
   * I am checking for the change in x/y.
   *
   * This provides a buffer for fast keypresses
   */
  moveLeft(): void {
    if (this.snake[0].x - this.snake[1].x === 0) this.velocity = { x: -1, y: 0 };
  }
  moveRight(): void {
    if (this.snake[0].x - this.snake[1].x === 0) this.velocity = { x: 1, y: 0 };
  }
  moveUp(): void {
    if (this.snake[0].y - this.snake[1].y === 0) this.velocity = { x: 0, y: -1 };
  }
  moveDown(): void {
    if (this.snake[0].y - this.snake[1].y === 0) this.velocity = { x: 0, y: 1 };
  }
  randomizeFood(): void {
    this.food = {
      x: Math.floor(Math.random() * this.width),
      y: Math.floor(Math.random() * this.height),
    };
    this.snake.forEach((snakePart) => {
      if (snakePart.x === this.food.x && snakePart.y === this.food.y) {
        this.randomizeFood();
      }
    });
  }
  draw(): void {
    this.ctx = this.cRef!.getContext("2d");
    // clear old drawing first
    this.ctx?.clearRect(0, 0, this.width * this.unit, this.height * this.unit);

    this.ctx!.fillStyle = this.color2;
    this.ctx!.fillRect(0, 0, this.width * this.unit, this.height * this.unit);
    this.ctx!.fillStyle = this.canvasColor;
    for (let i: number = 0; i < this.width; i += 1) {
      for (let j: number = 0; j < this.height; j += 1) {
        if ((i % 2 === 0 && j % 2 === 1) || (i % 2 === 1 && j % 2 === 0))
          this.ctx!.fillRect(i * this.unit, j * this.unit, this.unit, this.unit);
      }
    }
    this.drawSnake();
    this.drawFood();
  }
  drawSnake(): void {
    this.ctx!.beginPath();
    this.ctx!.fillStyle = this.snakeColor;
    let vec: Position = { x: 0, y: 0 };
    let vecBack: Position = { x: 0, y: 0 };
    this.snake.forEach((pos, i) => {
      if (i === 0) {
        vec.x = this.velocity.x;
        vec.y = this.velocity.y;
        this.drawSnakeHead(pos, vec);
      } else if (i === this.snake.length - 1) {
        vec.x = this.snake[i - 1].x - this.snake[i].x;
        vec.y = this.snake[i - 1].y - this.snake[i].y;
        this.drawSnakeTail(pos, vec);
      } else {
        vec.x = this.snake[i - 1].x - this.snake[i].x;
        vec.y = this.snake[i - 1].y - this.snake[i].y;
        vecBack.x = this.snake[i].x - this.snake[i + 1].x;
        vecBack.y = this.snake[i].y - this.snake[i + 1].y;
        if (vecBack.x === vec.x && vec.y === vecBack.y) this.drawSnakeBody(pos, vec);
        else this.drawCurvedSnake(pos, vec, vecBack);
      }
    });
    this.ctx!.closePath();
  }
  rotateSnakePart(pos: Position, vector: Position): void {
    this.ctx!.translate((pos.x + 0.5) * this.unit, (pos.y + 0.5) * this.unit);
    let angle: number = 0;

    if (vector.x === 1 && vector.y === 0) {
      angle = 0;
    } else if (vector.x === -1 && vector.y === 0) {
      angle = Math.PI;
    } else if (vector.x === 0 && vector.y === 1) {
      angle = Math.PI * 0.5;
    } else if (vector.x === 0 && vector.y === -1) {
      angle = Math.PI * 1.5;
    }
    this.ctx!.rotate(angle);
    this.ctx!.translate(-1 * (pos.x + 0.5) * this.unit, -1 * (pos.y + 0.5) * this.unit);
  }
  drawSnakeHead(pos: Position, vector: Position): void {
    this.ctx!.save();
    this.rotateSnakePart(pos, vector);
    this.ctx!.fillStyle = this.snakeColor;
    this.ctx!.beginPath();
    this.ctx!.moveTo(pos.x * this.unit, (pos.y + 0.2) * this.unit);

    this.ctx!.lineTo((pos.x + 0.2) * this.unit, pos.y * this.unit);
    this.ctx!.lineTo((pos.x + 1) * this.unit, (pos.y + 0.3) * this.unit);
    this.ctx!.lineTo((pos.x + 1) * this.unit, (pos.y + 0.7) * this.unit);
    this.ctx!.lineTo((pos.x + 0.2) * this.unit, (pos.y + 1) * this.unit);
    this.ctx!.lineTo(pos.x * this.unit, (pos.y + 0.8) * this.unit);
    this.ctx!.closePath();
    this.ctx!.fill();
    this.ctx!.fillStyle = "#777700";
    this.ctx!.beginPath();
    this.ctx!.arc(
      (pos.x + 0.7) * this.unit,
      (pos.y + 0.3) * this.unit,
      this.unit * 0.15,
      0,
      2 * Math.PI
    );
    this.ctx!.arc(
      (pos.x + 0.7) * this.unit,
      (pos.y + 0.7) * this.unit,
      this.unit * 0.15,
      0,
      2 * Math.PI
    );
    this.ctx!.fill();
    this.ctx!.restore();
  }
  drawSnakeTail(pos: Position, vector: Position): void {
    this.ctx!.save();
    this.rotateSnakePart(pos, vector);
    this.ctx!.fillStyle = this.snakeColor;
    this.ctx!.beginPath();
    this.ctx!.moveTo(pos.x * this.unit, (pos.y + 0.5) * this.unit);

    this.ctx!.lineTo((pos.x + 1) * this.unit, (pos.y + 0.2) * this.unit);
    this.ctx!.lineTo((pos.x + 1) * this.unit, (pos.y + 0.8) * this.unit);
    this.ctx!.closePath();
    this.ctx!.fill();
    this.ctx!.restore();
  }
  drawCurvedSnake(pos: Position, vector: Position, backVector: Position): void {
    // normalizedIsUp - a flag that is true when: if the backVector is rotated to point right,
    //                  then this flag is set to true when the front vector points up; false otherwise.
    // Checking the 4 possibilities carefully below...
    let normalizedIsUp: boolean = true;
    if (
      (backVector.x === 1 && vector.y === -1) ||
      (backVector.x === -1 && vector.y === 1) ||
      (backVector.y === 1 && vector.x === 1) ||
      (backVector.y === -1 && vector.x === -1)
    ) {
      normalizedIsUp = true;
    } else {
      normalizedIsUp = false;
    }
    this.ctx!.save();
    this.rotateSnakePart(pos, backVector);
    this.ctx!.fillStyle = this.snakeColor;

    this.ctx!.beginPath();
    if (normalizedIsUp) {
      this.ctx!.moveTo(pos.x * this.unit, (pos.y + 0.2) * this.unit);
      this.ctx!.quadraticCurveTo(
        (pos.x + 0.5) * this.unit,
        (pos.y + 0.5) * this.unit,
        (pos.x + 0.2) * this.unit,
        pos.y * this.unit
      );
      this.ctx!.lineTo((pos.x + 0.8) * this.unit, pos.y * this.unit);

      this.ctx!.quadraticCurveTo(
        (pos.x + 1) * this.unit,
        (pos.y + 1) * this.unit,
        pos.x * this.unit,
        (pos.y + 0.8) * this.unit
      );
    } else {
      this.ctx!.moveTo(pos.x * this.unit, (pos.y + 0.8) * this.unit);
      this.ctx!.quadraticCurveTo(
        (pos.x + 0.5) * this.unit,
        (pos.y + 0.5) * this.unit,
        (pos.x + 0.2) * this.unit,
        (pos.y + 1) * this.unit
      );
      this.ctx!.lineTo((pos.x + 0.8) * this.unit, (pos.y + 1) * this.unit);

      this.ctx!.quadraticCurveTo(
        (pos.x + 1) * this.unit,
        pos.y * this.unit,
        pos.x * this.unit,
        (pos.y + 0.2) * this.unit
      );
    }

    this.ctx!.closePath();
    this.ctx!.fill();
    this.ctx!.restore();
  }
  drawSnakeBody(pos: Position, vector: Position): void {
    // 1. Rotate the body part based on vector direction
    this.ctx!.save();
    this.rotateSnakePart(pos, vector);

    // 2. Draw the snake body part oriented right.
    this.ctx!.fillStyle = this.snakeColor;
    this.ctx!.beginPath();
    this.ctx!.moveTo(pos.x * this.unit, (pos.y + 0.2) * this.unit);
    this.ctx!.bezierCurveTo(
      (pos.x + 0.3) * this.unit,
      (pos.y + 0.4) * this.unit,
      (pos.x + 0.6) * this.unit,
      (pos.y - 0.1) * this.unit,
      (pos.x + 1) * this.unit,
      (pos.y + 0.2) * this.unit
    );
    this.ctx!.lineTo((pos.x + 1) * this.unit, (pos.y + 0.8) * this.unit);

    this.ctx!.bezierCurveTo(
      (pos.x + 0.6) * this.unit,
      (pos.y + 0.6) * this.unit,
      (pos.x + 0.3) * this.unit,
      (pos.y + 1) * this.unit,
      pos.x * this.unit,
      (pos.y + 0.8) * this.unit
    );
    this.ctx!.closePath();
    this.ctx!.fill();
    this.ctx!.restore();
  }
  drawFood(): void {
    this.ctx!.globalAlpha = 0.8;
    let radgrad = this.ctx!.createRadialGradient(
      (this.food.x + 0.4) * this.unit,
      (this.food.y + 0.4) * this.unit,
      0,
      (this.food.x + 0.5) * this.unit,
      (this.food.y + 0.5) * this.unit,
      this.unit
    );
    radgrad.addColorStop(0, "#aaaa00");
    radgrad.addColorStop(0.1, "#999922");
    radgrad.addColorStop(0.1, "#777733");
    radgrad.addColorStop(0.2, "#441505");
    radgrad.addColorStop(0.4, "#880101");
    radgrad.addColorStop(0.9, "#cc0000");
    radgrad.addColorStop(1, this.foodColor);
    this.ctx!.fillStyle = radgrad;
    /*
      this.ctx!.fillRect(
        (this.food.x + 0.2) * this.unit,
        (this.food.y + 0.2) * this.unit,
        0.6 * this.unit,
        0.6 * this.unit
      );
      */
    this.ctx!.beginPath();
    this.ctx!.arc(
      (this.food.x + 0.5) * this.unit,
      (this.food.y + 0.5) * this.unit,
      this.unit * 0.3,
      0,
      2 * Math.PI
    );
    this.ctx!.closePath();
    this.ctx!.fill();
  }
  arrowPressed(e: KeyboardEvent): void {
    // Game settings related keys pressed
    if (e.code === "KeyP") {
      self.togglePausePlay();
    }
    // arrows pressed - only when playing the game
    if (self.playingMode) {
      if (e.code === "ArrowUp") self.moveUp();
      else if (e.code === "ArrowDown") self.moveDown();
      else if (e.code === "ArrowLeft") self.moveLeft();
      else if (e.code === "ArrowRight") self.moveRight();
    }
  }
}
let snake: SnakeGame;

onMounted(() => {
  snake = new SnakeGame();
  document.addEventListener("keydown", snake.arrowPressed);
  snake.start().then(() => {
    // browser has an 'animation' delay that results in wrong width/height value.
    // calling start again after the delay solves this.
    // using Promise to get the right time, setTimeout() isn't accurate
    snake.start();
  });
  score.value = snake.score;
  // window.setTimeout(() => snake.start(), 5000);
});

const togglePausePlay = () => snake.togglePausePlay();
const moveUp = () => snake.moveUp();
const moveDown = () => snake.moveDown();
const moveLeft = () => snake.moveLeft();
const moveRight = () => snake.moveRight();
</script>

<template>
  <div class="dialog" v-show="dialog">
    <h1 class="dialog-title title">Snake Game</h1>
    <ul class="dialog-content">
      <li>
        Move the snake around and eat food to grow to get as high a score as possible
      </li>
      <li>The snake dies when it hits the border of the canvas or its own body</li>
      <li>Control the snake's direction via the arrow keys</li>
      <li>
        Toggle the game state to pause<strong>/</strong>play via pressing the 'P' key or
        the Play<strong>/</strong>Pause button
      </li>
    </ul>
  </div>
  <div class="container">
    <div class="title-container" ref="titleRef">
      <div class="title-big">
        <span class="main">
          <h1 class="title text-shadow-white green-font">Snake Game</h1>
          <span class="howto" @click="dialog = true">How to play</span>
        </span>
        <button class="button title-left" @click="togglePausePlay">
          {{ pausePlay }}
        </button>
      </div>
      <div class="title-small">
        <span class="title-item">
          <strong>SCORE:</strong>
          <span class="green-font"> {{ score }} </span>
        </span>
        <span class="title-item">
          <strong>HIGH SCORE:</strong>
          <span class="green-font"> {{ highscore }} </span>
        </span>
      </div>
    </div>

    <div class="canvas-container" ref="containerRef" @click="dialog = false">
      <canvas id="snakeCanvas" ref="canvasRef"> </canvas>
    </div>
  </div>
</template>

<style scoped>
#snakeCanvas {
  margin: 0;
  padding: 0;
  border: 5px ridge #aaaaaa;
  box-shadow: 0 5px 10px 10px rgb(256, 256, 256, 0.3);
}
.container {
  /*position: absolute;*/
}
.title-container {
  /*position: relative;*/
  --clr-green: #1b5e20;
  margin: 0;
  padding: 0;
  font-size: 1rem;
  display: flex;
  flex-flow: column wrap;
  align-items: center;
  text-align: center;
}
.title-big {
  display: flex;
  text-align: center;
  flex-flow: column wrap;
  align-items: center;
  margin: 0;
  padding: 0;
}
.title-small {
  margin: 0;
  padding: 0;
}
.main {
  margin: 0;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}
.title {
  margin: 0;
  padding: 0;
  font-size: 2.5rem;
  width: 12ch;
  text-align: center;
}
.title-left {
  flex: 1 1;
}
.howto {
  font-style: italic;
  color: #111111;
  cursor: pointer;
  align-self: flex-end;
  margin-bottom: 1rem;
  border-radius: 1rem;
}
.title-item {
  padding: 0;
  text-align: right;
  margin: 1rem 0.5rem;
}
.canvas-container {
  /* position: relative; */
  margin: 0;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  max-height: 100%;
}
.button {
  cursor: pointer;
  padding: 0.5em 1.25em;
  display: inline-block;
  color: white;
  background-color: var(--clr-green);
}
.dialog {
  --clr-green: #1b5e20;
  display: flex;
  position: fixed;
  align-items: center;
  flex-flow: column wrap;
  gap: 1rem;
  background: #ffffff;
  top: 50%;
  left: 50%;
  width: 80vw;
  height: 80vh;
  font-size: 1rem;
  padding: 1.5rem 1rem;
  margin: -40vh 0 0 -40vw;
  line-height: 1.6rem;
  border: .2rem solid #5E1B59;
  border-radius: 1rem;
  box-shadow: 0 4px 38rem 12rem var(--clr-green);
}
.dialog-title {
  flex: 0 1 min-content;
  color: white;
  text-shadow: -1px 0 3px #5E1B59, 0 1px 3px #5E1B59, 1px 0 3px #5E1B59, 0 -1px 3px #5E1B59;
}
.dialog-content {
  flex: 1 1 1;
  max-width: 70ch;
  list-style: square outside;
  margin: 0;
  padding: 0;
  border-left: 5px double var(--clr-green);
  padding-left: 1.5rem;
}
.green-font {
  color: var(--clr-green);
}
.text-shadow-white {
  text-shadow: -1px 0 1px white, 0 1px 1px white, 1px 0 1px white, 0 -1px 1px white;
}
@media (min-width: 750px) {
  .title-container {
    flex-direction: row;
  }
  .title-big {
    flex-direction: row;
    flex: 8;
    gap: 1rem;
    justify-content: center;
  }
  .title-small {
    flex: 4;
  }
  .main {
    flex: 6;
  }
  .howto {
    width: 12ch;
  }
  .dialog {
    width: 60vw;
    margin-left: -30vw;
  }
}
</style>
