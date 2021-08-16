/* eslint-disable @typescript-eslint/no-var-requires */
const manifest = require('./manifest.json');
import register from '../customElementWrapper';
import {
  customEvents as apiCustomEvents,
  observedAttributes as apiObservedAttributes,
} from '../partsApi';
import Popup from './Popup';
import { createSchema, schema, uiSchema } from './schema';

const observedAttributes: string[] = [...apiObservedAttributes];
const customEvents: any = { ...apiCustomEvents };

register(Popup, manifest.authoring.element, observedAttributes, {
  customEvents,
  shadow: false,
  customApi: {
    getSchema: () => schema,
    getUiSchema: () => uiSchema,
    createSchema,
  },
});