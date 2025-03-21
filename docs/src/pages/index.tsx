import type {ReactNode} from 'react';
import clsx from 'clsx';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';
import CodeBlockWrapper from "@theme/CodeBlock";

const HERO_CODE = `
# Step 1: Load the gem
require 'katachi'
Kt = Katachi
# Step 2: Describe the shape in plain Ruby
shape = {
    :$uuid => {
        email: :$email,
        first_name: String,
        last_name: String,
        dob: Kt::AnyOf[Date, nil],
        admin_only: Kt::AnyOf[
          {Symbol => String},
          :$undefined
        ],
        Symbol => Object,
    },
}
# Step 3: Check if you got a match
Kt.compare(api_response.body, shape).match?
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
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description={`Website for the "${siteConfig.title}" Open Source project`}>
      <HomepageHeader />
      <main style={{maxWidth: 800, marginLeft: 'auto', marginRight: 'auto', paddingTop: '1rem'
      }}>
        <CodeBlockWrapper language="ruby">{HERO_CODE}</CodeBlockWrapper>
      </main>
    </Layout>
  );
}
