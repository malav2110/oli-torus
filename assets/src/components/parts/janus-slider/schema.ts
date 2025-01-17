import { CapiVariableTypes } from '../../../adaptivity/capi';
import { JSONSchema7Object } from 'json-schema';
import { JanusAbsolutePositioned, JanusCustomCss } from '../types/parts';

export interface SliderModel extends JanusAbsolutePositioned, JanusCustomCss {
  showLabel: boolean;
  label: string;
  showDataTip: boolean;
  showValueLabels: boolean;
  showTicks: boolean;
  invertScale: boolean;
  minimum: number;
  maximum: number;
  snapInterval: number;
  enabled: boolean;
}

export const schema: JSONSchema7Object = {
  customCssClass: {
    title: 'Custom CSS Class',
    type: 'string',
  },
  showLabel: {
    title: 'Show Label',
    type: 'boolean',
    description: 'specifies whether label is visible',
    default: true,
  },
  label: {
    title: 'Label',
    type: 'string',
    description: 'text label for the slider',
  },
  showDataTip: {
    title: 'Show Data Tip',
    type: 'boolean',
  },
  showValueLabels: {
    title: 'Show Value Labels',
    type: 'boolean',
  },
  showTicks: {
    title: 'Show Ticks',
    type: 'boolean',
  },
  invertScale: {
    title: 'Invert Scale',
    type: 'boolean',
  },
  minimum: {
    title: 'Min',
    type: 'number',
  },
  maximum: {
    title: 'Max',
    type: 'number',
  },
  snapInterval: {
    title: 'Interval',
    type: 'number',
  },
  enabled: {
    title: 'Enabled',
    type: 'boolean',
    description: 'specifies whether slider is enabled',
    default: true,
  },
};

export const uiSchema = {};

export const adaptivitySchema = {
  value: CapiVariableTypes.NUMBER,
  userModified: CapiVariableTypes.BOOLEAN,
  enabled: CapiVariableTypes.BOOLEAN,
};

export const createSchema = (): Partial<SliderModel> => ({
  enabled: true,
  customCssClass: '',
  showLabel: true,
  showDataTip: true,
  showValueLabels: true,
  showTicks: true,
  showThumbByDefault: true,
  invertScale: false,
  minimum: 0,
  maximum: 100,
  snapInterval: 1,
  label: 'Slider',
});
