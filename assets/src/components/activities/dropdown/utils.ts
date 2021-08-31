import { DropdownModelSchema } from './schema';
import {
  Choice,
  HasParts,
  makeChoice,
  makeHint,
  makeResponse,
  makeStem,
  makeTransformation,
  Operation,
  ScoringStrategy,
} from '../types';
import { matchRule } from 'components/activities/common/responses/authoring/rules';
import {
  getCorrectResponse,
  getIncorrectResponse,
  getResponses,
} from 'components/activities/common/responses/authoring/responseUtils';
import { DEFAULT_PART_ID } from 'components/activities/common/utils';

export const defaultModel: () => DropdownModelSchema = () => {
  const choiceA: Choice = makeChoice('Choice A');
  const choiceB: Choice = makeChoice('Choice B');

  return {
    stem: makeStem(''),
    choices: [choiceA, choiceB],
    authoring: {
      parts: [
        {
          id: DEFAULT_PART_ID,
          scoringStrategy: ScoringStrategy.average,
          responses: [
            makeResponse(matchRule(choiceA.id), 1, ''),
            makeResponse(matchRule('.*'), 0, ''),
          ],
          hints: [makeHint(''), makeHint(''), makeHint('')],
        },
      ],
      targeted: [],
      transformations: [makeTransformation('choices', Operation.shuffle)],
      previewText: '',
    },
  };
};

export const getTargetedResponses = (model: HasParts) =>
  getResponses(model).filter(
    (response) =>
      response !== getCorrectResponse(model, DEFAULT_PART_ID) &&
      response !== getIncorrectResponse(model, DEFAULT_PART_ID),
  );
