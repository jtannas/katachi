import type {ReactNode} from 'react';
import clsx from 'clsx';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';

import styles from './index.module.css';
import CodeBlockWrapper from "../theme/CodeBlock";

var HERO_CODE = `
  shape = {
      :$uuid => {
          email: :$email,
          first_name: String,
          last_name: String,
          preferred_name: AnyOf[String, nil],
          admin_only_information: AnyOf[{Symbol => String}, :$undefined],
          Symbol => Object,
      },
  }
  expect(value: api_response.body, shape:).to be_match
`

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div style={{backgroundColor: 'yellow', color: 'black', fontWeight: 'bold', maxWidth: '100rem'}}>Site Still Under Construction</div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description={`Website for the Open Source project: ${siteConfig.title}`}>
      <HomepageHeader />
      <main>
        <CodeBlockWrapper language="ruby">{HERO_CODE}</CodeBlockWrapper>
      </main>
    </Layout>
  );
}
