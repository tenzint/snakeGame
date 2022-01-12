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
  console.log(snake.score);
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
  snake: Position[];
  velocity: Position;
  setInterval: number;
  food: Position;
  score: number;
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
    this.snakeColor = "#00cc00";
    this.snake = [];
    this.velocity = { x: 1, y: 0 };
    this.setInterval = 0;
    this.food = { x: Math.random() * this.width, y: Math.random() * this.height };
    this.score = this.snake.length;
  }
  setup(): void {
    if (window.innerWidth >= 1080) this.unit = 40;
    else if (window.innerWidth >= 720) this.unit = 30;
    else this.unit = 20;
    containerRef!.value.style.height =
      window.innerHeight - titleRef!.value.offsetHeight + "px";

    let widthRatio = 1;
    if (window.innerWidth >= 600) widthRatio = 0.8;
    this.cRef!.width =
      Math.floor((window.innerWidth * widthRatio) / this.unit) * this.unit;
    this.cRef!.height =
      Math.floor((window.innerHeight - titleRef.value.offsetHeight) / this.unit) *
      this.unit;
    this.width = Math.floor(this.cRef!.width / this.unit);
    this.height = Math.floor(this.cRef!.height / this.unit);
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
    if (this.setInterval) clearInterval(this.setInterval);
    this.setInterval = setInterval(() => this.moveNext(), 200);
  }
  updateScore(): void {
    this.score = this.snake.length;
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
    if (highscore.value < this.score) {
      highscore.value = this.score;
    }
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
    this.ctx!.fillStyle = "#cc0000";
    this.ctx!.fillRect(
      this.food.x * this.unit,
      this.food.y * this.unit,
      this.unit,
      this.unit
    );
  }
  arrowPressed(e: KeyboardEvent): void {
    if (e.code === "ArrowUp") self.moveUp();
    else if (e.code === "ArrowDown") self.moveDown();
    else if (e.code === "ArrowLeft") self.moveLeft();
    else if (e.code === "ArrowRight") self.moveRight();
  }
}
</script>

<template>
  <div class="title-container" ref="titleRef">
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
}
.title-container {
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: row;
  background: rgba(128, 128, 128, 0.5);
}
.container {
  margin: 0;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  max-height: 100%;
}
</style>
