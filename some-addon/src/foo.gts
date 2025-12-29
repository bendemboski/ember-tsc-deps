import GlimmerComponent from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class Foo extends GlimmerComponent {
  @tracked count = 0;

  <template>{{this.count}}</template>
}

export const t = <template><Foo /></template>;
