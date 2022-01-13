<script setup lang="ts">
import { ref, onMounted } from "vue";
var canvasRef = ref<HTMLCanvasElement | null | undefined>(null);
var titleRef = ref<HTMLDivElement | null>(null);
var containerRef = ref<HTMLDivElement | null>(null);
let self: SnakeGame;
let score = ref<number>(0);
let highscore = ref<number>(0);
interface Position {
  x: number;
  y: number;
}

onMounted(() => {
  const snake = new SnakeGame();
  document.addEventListener("keydown", snake.arrowPressed);
  snake.start();
  score.value = snake.score;
});
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
  }
  setup(): void {
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
  }
  cleanTimer(): void {
    clearInterval(this.timer);
  }
  togglePausePlay(): void {
    if (this.playingMode) {
      // Playing; pause the game
      this.playingMode = false;
      if (this.timer) this.cleanTimer();
    } else {
      // Paused; play the game
      this.playingMode = true;
      if (this.timer) this.cleanTimer();
      this.timer = setInterval(() => this.moveNext(), 150);
    }
  }
  start(): void {
    this.setup();
    let halfW = Math.floor(this.width / 2);
    let halfH = Math.floor(this.height / 2);
    this.snake = [];
    this.velocity = { x: 1, y: 0 };
    this.food = { x: Math.random() * this.width, y: Math.random() * this.height };
    this.snake.push({ x: halfW, y: halfH });
    this.snake.push({ x: halfW - 1, y: halfH });
    this.snake.push({ x: halfW - 2, y: halfH });
    this.snake.push({ x: halfW - 3, y: halfH });
    this.snake.push({ x: halfW - 4, y: halfH });
    this.updateScore();
    this.randomizeFood();
    this.playingMode = false;
    this.moveNext();
  }
  updateScore(): void {
    this.score = this.snake.length;
    score.value = this.score;
  }
  didSnakeEat(): boolean {
    if (this.snake[0].x === this.food.x && this.snake[0].y === this.food.y) {
      this.randomizeFood();
      this.updateScore();
      return true;
    } else return false;
  }
  restart(): void {
    // keep code dry. Some restart codes here
    if (highscore.value < score.value) {
      highscore.value = score.value;
    }
    this.cleanTimer();
    this.playingMode = false;
    this.start();
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
    this.ctx?.clearRect(0, 0, this.width * this.unit, this.height * this.unit);
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
    this.snake.forEach((pos) => {
      this.ctx!.rect(pos.x * this.unit, pos.y * this.unit, this.unit, this.unit);
      this.ctx!.fill();
    });
    this.ctx!.closePath();
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
    radgrad.addColorStop(0, "#ffff00");
    radgrad.addColorStop(0.1, "#999922");
    radgrad.addColorStop(0.1, "#777733");
    radgrad.addColorStop(0.2, "#441505");
    radgrad.addColorStop(0.3, "#880101");
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
</script>

<template>
  <div class="title-container" ref="titleRef">
    <h1 class="title">Snake Game</h1>
    <span class="title-item">SCORE: {{ score }}</span>
    <span class="title-item">HIGH SCORE: {{ highscore }}</span>
  </div>

  <div class="container" ref="containerRef">
    <canvas id="snakeCanvas" ref="canvasRef"> </canvas>
  </div>
</template>

<style scoped>
#snakeCanvas {
  margin: 0;
  padding: 0;
  border: 5px ridge #aaaaaa;
}
.title-container {
  margin: 0;
  padding: 0;
  display: flex;
  flex-flow: row wrap;
  align-items: center;
  justify-content: center;
  background: rgba(128, 128, 128, 0.5);
}
@media (max-width: 800px) {
  .title-container {
    flex-direction: column;
  }
}
.container {
  margin: 0;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  max-height: 100%;
}
.title {
  margin: 1rem 2rem;
  padding: 0;
  font-size: 1.5rem;
  flex-grow: 10;
  text-align: center;
}
.title-item {
  margin: 1rem 1rem;
  padding: 0;
  flex-grow: 1;
  text-align: right;
}
</style>
