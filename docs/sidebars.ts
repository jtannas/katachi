import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  // By default, Docusaurus generates a sidebar from the docs folder structure
  // docsSidebar: [{type: 'autogenerated', dirName: '.'}],
  docsSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Features',
      description: 'Explore the features of Katachi',
      items: [{ type: 'autogenerated', dirName: 'Features' }],
      collapsed: false,
    },
    {
      type: 'category',
      label: 'Integrations',
      description: 'Integrations with other tools',
      items: [{ type: 'autogenerated', dirName: 'Integrations' }],
      collapsed: false,
    }
  ],
  contributingSidebar: [
    { type: 'autogenerated', dirName: 'Contributing'},
  ],

  // But you can create a sidebar manually
  // tutorialSidebar: [
  //   {
  //     type: 'category',
  //     label: 'Contributing',
  //     items: ['./Contributing'],
  //   },
  // ],
};

export default sidebars;
