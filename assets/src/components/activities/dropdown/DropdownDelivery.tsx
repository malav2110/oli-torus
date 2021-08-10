import React, { useEffect } from 'react';
import ReactDOM from 'react-dom';
import {
  DeliveryElement,
  DeliveryElementProps,
  DeliveryElementProvider,
  useDeliveryElementContext,
} from '../DeliveryElement';
import { DropdownModelSchema } from './schema';
import * as ActivityTypes from '../types';
import { valueOr } from 'utils/common';
import { StemDeliveryConnected } from 'components/activities/common/stem/delivery/StemDeliveryConnected';
import { GradedPointsConnected } from 'components/activities/common/delivery/gradedPoints/GradedPointsConnected';
import { ResetButtonConnected } from 'components/activities/common/delivery/resetButton/ResetButtonConnected';
import { SubmitButtonConnected } from 'components/activities/common/delivery/submitButton/SubmitButtonConnected';
import { HintsDeliveryConnected } from 'components/activities/common/hints/delivery/HintsDeliveryConnected';
import { EvaluationConnected } from 'components/activities/common/delivery/evaluation/EvaluationConnected';
import { Provider, useDispatch, useSelector } from 'react-redux';
import {
  ActivityDeliveryState,
  initializeState,
  isEvaluated,
  activityDeliverySlice,
  resetAction,
} from 'data/content/activities/DeliveryState';
import { configureStore } from 'state/store';
import { safelySelectInput } from 'data/content/activities/utils';

type InputProps = {
  input: string;
  onChange: (input: any) => void;
  inputType: InputType;
  isEvaluated: boolean;
};

const Input = (props: InputProps) => {
  const input = valueOr(props.input, '');

  if (props.inputType === 'numeric') {
    return (
      <input
        type="number"
        aria-label="answer submission textbox"
        className="form-control"
        onChange={(e: any) => props.onChange(e.target.value)}
        value={input}
        disabled={props.isEvaluated}
      />
    );
  }
  if (props.inputType === 'text') {
    return (
      <input
        type="text"
        aria-label="answer submission textbox"
        className="form-control"
        onChange={(e: any) => props.onChange(e.target.value)}
        value={input}
        disabled={props.isEvaluated}
      />
    );
  }
  return (
    <textarea
      aria-label="answer submission textbox"
      rows={5}
      cols={80}
      className="form-control"
      onChange={(e: any) => props.onChange(e.target.value)}
      value={input}
      disabled={props.isEvaluated}
    ></textarea>
  );
};

export const DropdownComponent: React.FC = () => {
  const {
    model,
    state: activityState,
    onSaveActivity,
    onResetActivity,
  } = useDeliveryElementContext<DropdownModelSchema>();
  const uiState = useSelector((state: ActivityDeliveryState) => state);

  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(
      initializeState(
        activityState,
        // Short answers only have one input, but the selection is modeled
        // as an array just to make it consistent with the other activity types
        safelySelectInput(activityState).caseOf({
          just: (input) => [input],
          nothing: () => [''],
        }),
      ),
    );
  }, []);

  // First render initializes state
  if (!uiState.attemptState) {
    return null;
  }

  const onInputChange = (input: string) => {
    dispatch(activityDeliverySlice.actions.setSelection([input]));

    onSaveActivity(uiState.attemptState.attemptGuid, [
      { attemptGuid: uiState.attemptState.parts[0].attemptGuid, response: { input } },
    ]);
  };

  return (
    <div className="activity cata-activity">
      <div className="activity-content">
        <StemDeliveryConnected />
        <GradedPointsConnected />

        <Input
          inputType={model.inputType}
          // Short answers only have one selection, but are modeled as an array.
          // Select the first element.
          input={uiState.selection[0]}
          isEvaluated={isEvaluated(uiState)}
          onChange={onInputChange}
        />

        <ResetButtonConnected onReset={() => dispatch(resetAction(onResetActivity, ['']))} />
        <SubmitButtonConnected />
        <HintsDeliveryConnected />
        <EvaluationConnected />
      </div>
    </div>
  );
};

// Defines the web component, a simple wrapper over our React component above
export class DropdownDelivery extends DeliveryElement<DropdownModelSchema> {
  render(mountPoint: HTMLDivElement, props: DeliveryElementProps<DropdownModelSchema>) {
    const store = configureStore({}, activityDeliverySlice.reducer);
    ReactDOM.render(
      <Provider store={store}>
        <DeliveryElementProvider {...props}>
          <DropdownComponent />
        </DeliveryElementProvider>
      </Provider>,
      mountPoint,
    );
  }
}

// Register the web component:
// eslint-disable-next-line
const manifest = require('./manifest.json') as ActivityTypes.Manifest;
window.customElements.define(manifest.delivery.element, DropdownDelivery);
