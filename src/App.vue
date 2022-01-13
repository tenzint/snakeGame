<script setup lang="ts">
import Snake from "./components/Snake.vue";

components: {
  Snake;
}
</script>

<template>
  <Snake></Snake>
</template>

<style>
document,
html,
body,
#app {
  margin: 0;
  font-size: 1em;
  line-height: 2;
  background-color: rgba(128, 128, 128, 0.3);
  max-height: 100vh;
}

*,
::before,
::after {
  transition: all ease-in-out 250ms;
  box-sizing: border-box;
}
</style>
