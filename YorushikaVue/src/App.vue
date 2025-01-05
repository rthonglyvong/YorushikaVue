<template>
  <div id="app">
    <audio id="background-music" autoplay loop>
      <source :src="currentBgm" type="audio/mpeg">
      Your browser does not support the audio element.
    </audio>
    <div id="pageflip-container" style="background-image: url('/background.jpg'); background-size: cover; background-position: center;">
      <!-- First Cover Page -->
      <div class="page page-cover" data-density="hard">
        <div class="page-content">
          <h2>{{ pages[0].content.title }}</h2>
          <p>{{ pages[0].content.body }}</p>
        </div>
      </div>

      <!-- Dynamic Pages -->
      <div v-for="(page, index) in pages.slice(1, pages.length - 1)" :key="index" class="page" :data-type="page.type">
        <div class="page-content">
          <h2>{{ page.content.title }}</h2>
          <p v-if="page.type === 'Text'" v-html="convertNewlines(page.content.body)"></p>
          <iframe v-if="page.type === 'Video'" :src="'https://www.youtube.com/embed/' + getVideoId(page.content.body)" width="100%" height="60%" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
          <img v-if="page.type === 'Image'" :src="page.content.body" alt="Page image" style="max-width:100%; max-height:100%; object-fit:contain;">
        </div>
      </div>

      <!-- Last Cover Page -->
      <div class="page page-cover" data-density="hard">
        <div class="page-content">
          <h2>{{ pages[pages.length - 1].content.title }}</h2>
          <p>{{ pages[pages.length - 1].content.body }}</p>
        </div>
      </div>
    </div>
    <div class="controls">
      <button id="audio-toggle" @click="toggleBgm">{{ isMuted ? 'Unmute' : 'Mute' }}</button>
      <button @click="flipPrev">Previous</button>
      <button @click="flipNext">Next</button>
      <select v-model="selectedLanguage" @change="changeLanguage">
        <option value="en">English</option>
        <option value="kr">한국어</option>
        <option value="jp">日本語</option>
        <option value="cn">中文</option>
      </select>
    </div>
  </div>
</template>

<script>
import { PageFlip } from 'page-flip';
import pagesData from '@/content/pages.json';
import pagesEnData from '@/content/pages.en.json';
import pagesKrData from '@/content/pages.kr.json';
import pagesJpData from '@/content/pages.jp.json';
import pagesCnData from '@/content/pages.cn.json';

export default {
  name: 'App',
  data() {
    return {
      selectedLanguage: 'en', // Default language
      pageFlip: null,
      pages: pagesData,
      pagesEnData: pagesEnData,
      pagesKrData: pagesKrData,
      pagesJpData: pagesJpData,
      pagesCnData: pagesCnData,
      bgmFiles: {},  // Store preloaded audio objects by filename
      currentBgm: '', // Track the current BGM file
      isMuted: false,
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.initPageFlip();
      this.preloadBgm();  // Preload all BGM files
      this.updateAudioState(); // Set initial bgm after pageFlip is initialized
    });
  },
  methods: {
    getVideoId(url) {
      let languageCode;
      switch (this.selectedLanguage) {
        case 'jp':
          languageCode = 'ja'; // Japanese
          break;
        case 'kr':
          languageCode = 'ko'; // Korean
          break;
        case 'en':
          languageCode = 'en'; // English
          break;
        case 'cn':
          languageCode = 'zh-CN'; // Simplified Chinese (Mandarin)
          break;
        default:
          languageCode = 'en'; // Default to English if no match
          break;
      }
      console.log("video selected language: " + languageCode)
      const videoIdMatch = url.match(/(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|(?:.*[?&]v=))|(?:youtu\.be\/))([\w\-]+)/);
      return videoIdMatch ? videoIdMatch[1]+`?cc_load_policy=1&cc_lang_pref=${this.languageCode}` : null;
    },
    convertNewlines(text) {
      return text.replace(/\n/g, '<br>');
    },
    // Preload all BGM files
    preloadBgm() {
      this.pages.forEach((page, index) => {
        if (page.bgm && !this.bgmFiles[page.bgm]) { // Only preload if not already done
          console.log(`Preloading BGM: /music/${page.bgm}`);
          const audio = new Audio(`/music/${page.bgm}`);
          this.bgmFiles[page.bgm] = audio; // Store the audio objects by the BGM filename (e.g., "01.mp3")
        }
      });
    },
    
    getLanguageClass() {
      switch (this.selectedLanguage) {
        case 'en':
          return 'en';
        case 'kr':
          return 'kr';
        case 'jp':
          return 'jp';
        case 'cn':
          return 'cn';
        default:
          return '';
      }
    },
    // Change the language when the user selects a different option
    changeLanguage(event) {
      this.selectedLanguage = event.target.value;
      // Optionally, update pages based on selected language here
      this.updatePageContent();
    },
    updatePageContent() {
      // You can load the corresponding pages data here based on the selected language
      switch (this.selectedLanguage) {
        case 'en':
          this.pages = this.pagesEnData;
          break;
        case 'kr':
          this.pages = this.pagesKrData;
          break;
        case 'jp':
          this.pages = this.pagesJpData;
          break;
        case 'cn':
          this.pages = this.pagesCnData;
          break;
      }
    },
    initPageFlip() {
      const container = document.getElementById('pageflip-container');
      this.pageFlip = new PageFlip(container, {
        width: 550,
        height: 733,
        size: 'stretch',
        minWidth: 315,
        maxWidth: 1000,
        minHeight: 420,
        maxHeight: 1350,
        maxShadowOpacity: 0.5,
        flippingTime: 1500,
        showCover: true,
        mobileScrollSupport: false,
        usePortrait: true,
      });

      this.pageFlip.loadFromHTML(container.querySelectorAll('.page'));

      // Update audio state after page flip
      this.pageFlip.on('flip', () => {
        this.updateAudioState();
      });
    },
    
    updateAudioState() {
      const audioElement = document.getElementById('background-music');
      const currentPage = this.pageFlip.getCurrentPageIndex();
      const nextPage = currentPage + 1;
      const isPortrait = window.innerHeight > window.innerWidth; // Portrait mode
      const isLandscape = window.innerWidth > window.innerHeight; // Landscape mode

      console.log(`Current Orientation: ${isPortrait ? 'Portrait' : 'Landscape'}`);

      let visiblePages = [currentPage, nextPage];
      let highestPriorityBgm = this.currentBgm;
      let shouldMute = false;
      if (isPortrait) {
        visiblePages = visiblePages.slice(0, 1)
      }
      // Find the BGM of the visible pages
      visiblePages.forEach((pageIndex) => {
        const page = this.pages[pageIndex];
        if (page && page.type === 'Video') {
          shouldMute = true; // Mute if a video is displayed
        }
        if (page && page.bgm) {
          highestPriorityBgm = page.bgm; // Update the highest priority BGM based on visible pages
        }
      });

      // Check if the selected BGM exists in bgmFiles
      console.log(`Selected BGM: ${highestPriorityBgm}`);
      if (this.bgmFiles[highestPriorityBgm]) {
        // If a new BGM is selected, update and play it
        if (shouldMute) {
          let fadeDuration = 2000; // 2 seconds
          let fadeStep = 0.05; // Decrease volume by 0.05 each step
          let fadeInterval = 50; // Interval time for each fade step (in ms)
          let volume = audioElement.volume;

          // Gradually decrease the volume
          let fadeOutInterval = setInterval(() => {
            if (volume > 0) {
              volume -= fadeStep;  // Reduce volume
              audioElement.volume = volume;  // Set new volume
            } else {
              clearInterval(fadeOutInterval);  // Stop when volume reaches 0
              audioElement.pause();  // Pause the audio
            }
          }, fadeInterval);
        } else if (highestPriorityBgm !== this.currentBgm) {
          this.currentBgm = highestPriorityBgm; // Set the new BGM
          const newBgm = this.bgmFiles[highestPriorityBgm]; // Get the audio object
          audioElement.src = newBgm.src; // Update the audio element's source
          if (audioElement.paused && !this.isMuted) {
            audioElement.play(); // Play the new BGM
          }
        } else if (audioElement.paused) {
          let fadeDuration = 2000; // 2 seconds
          let fadeStep = 0.05; // Decrease volume by 0.05 each step
          let fadeInterval = 50; // Interval time for each fade step (in ms)
          let volume = audioElement.volume;

          // Gradually decrease the volume
          let fadeOutInterval = setInterval(() => {
            if (volume < 1) {
              volume += fadeStep;  // Reduce volume
              audioElement.volume = volume;  // Set new volume
            } else {
              clearInterval(fadeOutInterval);  // Stop when volume reaches 0
              audioElement.play();  // Pause the audio
            }
          }, fadeInterval);
        }
      } else {
        console.error(`Selected BGM does not exist in bgmFiles: ${highestPriorityBgm}`);
      }
    },
    // Method to flip to the next page
    flipNext() {
      this.pageFlip.flipNext();
    },

    // Method to flip to the previous page
    flipPrev() {
      this.pageFlip.flipPrev();
    },
    // Toggle BGM mute/unmute
    toggleBgm() {
      const audioElement = document.getElementById('background-music');
      this.isMuted = !this.isMuted;
      if (this.isMuted) {
        audioElement.pause();
      } else {
        audioElement.play();
      }
    },
  },
  watch: {
    selectedLanguage: 'changeLanguage' // Watch for changes in selected language
  },
};
</script>

<style>
body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 0;
}
#app {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  background-color: #f4f4f4;
}
.controls {
  margin-top: 20px;
}
button {
  margin: 5px;
  padding: 10px 20px;
  cursor: pointer;
}
.flip-book {
  box-shadow: 0 0 20px 0 rgba(0, 0, 0, 0.5);
  display: none;
  background-size: cover;
}
.page {
  padding: 20px;
  background-color: hsl(35, 55%, 98%);
  color: #274C77;
  border: solid 1px hsl(35, 20%, 70%);
  overflow: hidden;
  font-family: 'Dancing Script', cursive;
  font-size: 1.1em;
  line-height: 1.6;
  text-align: center;
}
.page-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  width: 100%;
  text-align: center;
}

select {
  margin: 5px;
  padding: 10px 20px;
  cursor: pointer;
  font-size: 14px;
  background-color: #f0f0f0;
  color: #333;
  border: solid 1px #120997;
  border-radius: 5px;
  appearance: none; /* Removes default dropdown arrow */
  -webkit-appearance: none; /* Removes dropdown for Safari */
  -moz-appearance: none; /* Removes dropdown for Firefox */
}
/* Optional: Adding media queries for further control */
@media (max-width: 768px) {
  .page {
    font-size: .7em; /* Larger font size for tablets */
  }
}

@media (max-width: 480px) {
  .page {
    font-size: .7em; /* Larger font size for mobile */
  }
}
</style>
