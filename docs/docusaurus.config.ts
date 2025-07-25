import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

// cspell:words jtannasio YQH772IVVK

const config: Config = {
  title: 'Katachi',
  tagline: 'A Ruby tool for describing objects as intuitively as possible',
  favicon: 'img/favicon.ico',

  url: 'https://jtannas.github.io/',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/katachi/',

  // GitHub pages deployment config.
  organizationName: 'jtannas',
  projectName: 'katachi',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/jtannas/katachi/tree/main/docs/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'Katachi',
      logo: {
        alt: 'Katachi Logo',
        src: 'img/logo.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          type: 'docSidebar',
          sidebarId: 'contributingSidebar',
          position: 'left',
          label: 'Contributing',
        },
        {
          href: 'https://github.com/jtannas/katachi',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          label: 'GitHub',
          href: 'https://github.com/jtannas/katachi',
        },
        {
          label: 'RubyGems',
          href: 'https://rubygems.org/gems/katachi',
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Joel Tannas. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.vsLight,
      darkTheme: prismThemes.vsDark,
      additionalLanguages: ['ruby', 'diff'],
    },
    algolia: {
      appId: 'YQH772IVVK',
      apiKey: '64b82568a0baceb87a6ec3ab7d40fde2',
      indexName: 'jtannasio',
    },
  } satisfies Preset.ThemeConfig,
  plugins: [
    [
      "posthog-docusaurus",
      { apiKey: "phc_CNDu1lfT2NF1WKrKWNMIaMiWiYzd7cAX7XQPLIYkM1r" },
    ],
  ],
};

export default config;
